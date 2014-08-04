require 'mongoid'
require 'csv'
require 'descriptive_statistics'
require 'fileutils'
require './app/models/exam.rb'

class Job
    include Mongoid::Document
    field :status, type: String
    field :worker, type: String
    field :job_start, type: Time
    field :job_stop, type: Time
    field :message, type: String
    field :data_file, type: String
    field :key_file, type: String
    field :created_at, type: Time
    field :updated_at, type: Time

  PENDING = "Pending"
  PROCESSING = "Processing"
  DONE = "Done" 
  ERROR = "Error"

  attr_accessor :exam

  #
  # Grab the next job to process from the DB
  #
  def self.get_next_job_to_process
    job = Job.where("status = '#{PENDING}'").order("job_start ASC").first
    unless job.nil?
      job.status = PROCESSING
      job.worker = ENV["WORKER_NAME"] || "localhost"
      job.job_start = utc_now
      job.save!
      job.exam = Exam.new
      job
    end
  end

  #
  # Creates the temp dir for a particular job
  #
  def create_directories
    Dir.mkdir "#{Settings.TMP_DIR}#{id}"
  end

  #
  # Scores the exam
  #
  def score_exam
    system("Rscript ./app/r/score_exam.R #{data_file_to_process} #{key_file_to_process} #{scored_filename} #{histogram_filename}")
  end

  #
  # Runs the analysis
  #
  def run_item_analysis
    system("Rscript ./app/r/item_analysis.R #{scored_filename} #{item_analysis_filename} #{scatter_plot_filename} #{exam.question_count}")
  end

  def perform_distractor_analysis
    system("Rscript ./app/r/distractor_analysis.R #{data_file_to_process} #{key_file_to_process} #{distractor_analysis_filename}")
  end

  def generate_expected_scores
    if Settings.RUN_MIRT?
      system("Rscript ./app/r/expected_score.R #{scored_filename} #{exam.question_count} #{temp_dir} #{id}")
    else
      true
    end
  end

  def set_summary_exam_info
    table = CSV::table(scored_filename, headers: true)

    self.exam.examinee_count = table.size
    self.exam.question_count = table.by_row[0].count - 2

    total_score_col = table.by_col[1]
    self.exam.mean = total_score_col.mean
    self.exam.std_dev = total_score_col.standard_deviation
  end

  #
  # Update the status of the job to done, and set job finished time stamp
  #
  def finish_processing
    if Settings.SKIP_S3_UPLOAD?
      # move the PDF file to the local output directory
      output_file_name = "./output/#{File.basename(pdf_filename)}"
      File.rename(pdf_filename, output_file_name) if File.exists?(pdf_filename)
    elsif Settings.CLEAN_S3_TEMP?
      clean_S3_temp_files
    end

    if Settings.CLEAN_LOCAL_TEMP?
      FileUtils.rm_rf temp_dir
    end

    self.status = DONE
    self.job_stop = Job.utc_now
    self.save!
  end

  #
  # Update status of job to error, set finished time stamp, 
  # set message if supplied
  #
  def stop_processing_due_to_error(message = nil)
    self.status = ERROR
    self.job_stop = Job.utc_now
    self.message = message unless message.nil?
    self.save!
  end

  def temp_dir
    "#{Settings.TMP_DIR}#{id}/"
  end

  def pdf_filename
    unless data_file.nil?
      "#{temp_dir}item_analysis_#{id}.pdf"
    end
  end

  def item_analysis_filename
    unless data_file.nil?
      "#{temp_dir}#{id}.item_analysis"
    end
  end

  def scatter_plot_filename
    unless data_file.nil?
      "#{temp_dir}#{id}.scatter.svg"
    end
  end

  def scored_filename
    unless data_file.nil?
      "#{temp_dir}#{id}.scored"
    end
  end

  def histogram_filename
    unless data_file.nil?
      "#{temp_dir}#{id}.histogram.svg"
    end
  end

  def distractor_analysis_filename
    unless data_file.nil?
      "#{temp_dir}#{id}.distractor_analysis"
    end
  end

  def expected_filename(question_number)
    unless data_file.nil?
      "#{temp_dir}#{id}.expected_#{question_number}.svg"
    end
  end

  def data_file_to_process
    unless data_file.nil?
      if Settings.PULL_INPUT_FILES_FROM_S3?
        S3.download_file(data_file, id)
      else
        data_file
      end
    end
  end

  def key_file_to_process
    unless data_file.nil?
      if Settings.PULL_INPUT_FILES_FROM_S3?
        S3.download_file(key_file, id)
      else
        key_file
      end
    end
  end

  private

    def self.utc_now
      Time.now.utc.strftime('%Y-%m-%d %H:%M:%S %Z')
    end

    def clean_S3_temp_files
      S3.delete(distractor_analysis_filename, id)
      S3.delete(histogram_filename, id)
      S3.delete(item_analysis_filename, id)
      S3.delete(scatter_plot_filename, id)
      S3.delete(scored_filename, id)
      exam.questions.each do |question|
        S3.delete(expected_filename(question.number), id)
      end
    end
end
