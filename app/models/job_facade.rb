require './app/models/job'
require './app/models/question'
require './app/models/distractor'
require './app/pdfs/item_analysis_pdf'
require './app/services/logging'

# class to provide a simplified public interface into the job class
class JobFacade
  #
  # Executes a job if one exists
  #   Job.process_next
  #   # => processes the next job (if one exists)
  #   # => returns true if a job was found to process, false otherwise 
  #
  def self.process_next
    job = Job.get_next_job_to_process

    unless job.nil?
      begin
        process(job)
      rescue => e
        job.stop_processing_due_to_error(e.message)
        Logging.error(e.message)
        Logging.error(e.backtrace)
      end
    end

    !job.nil?
  end

  private 
    def self.process(job)

      Logging.info "Processing job, input file: \"#{job.data_file}\""

      job.create_directories

      # score the exam
      scored = job.score_exam

      if scored  
        S3.upload(job.scored_filename, job.id)
        S3.upload(job.histogram_filename, job.id)

        # get some basic information about the job
        # NOTE using local not S3 version of scored here - bad?
        job.set_summary_exam_info 

        # run the item analysis
        # note using local not S3 version of scored here - bad?
        item_analysis_succeeded = job.run_item_analysis()
      else
        Logging.info "Not scored"
      end

      if scored && item_analysis_succeeded
        S3.upload(job.item_analysis_filename, job.id)
        S3.upload(job.scatter_plot_filename, job.id)

        # build the questions from the analysis
        job.exam.questions = Question.build_questions_from_string(S3.get(job.item_analysis_filename, job.id))

        # run the distractor analysis
        distractor_analysis_succeeded = job.perform_distractor_analysis
      end

      if scored && item_analysis_succeeded && distractor_analysis_succeeded
        S3.upload(job.distractor_analysis_filename, job.id)

        # build the distractors from the analysis
        Distractor.build_distractors_from_string(job.exam.questions,
          S3.get(job.distractor_analysis_filename, job.id))

        expected_analysis_succeeded = job.generate_expected_scores
      end

      if scored && item_analysis_succeeded && distractor_analysis_succeeded && expected_analysis_succeeded
        if Settings.RUN_MIRT?
          for index in 1..job.exam.question_count do
            S3.upload(job.expected_filename(index), job.id)
          end
        end

        # create PDF
        ItemAnalysisPdf.create(job)

        # upload PDF
        S3.upload(job.pdf_filename, job.id, tmp = false)
        
        # finish up the job
        job.finish_processing
        Logging.info "**** JOB COMPLETED SUCCESSFULLY ****"
      else
        Logging.info "!!!! JOB DID NOT COMPLETE SUCCESSFULLY !!!!"
      end
      
      if !scored
        job.stop_processing_due_to_error("Scoring failed")
      elsif !item_analysis_succeeded
        job.stop_processing_due_to_error("Item analysis failed")
      elsif !distractor_analysis_succeeded
        job.stop_processing_due_to_error("Distractor analysis failed")
      end
    end
end