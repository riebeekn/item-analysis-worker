class ItemAnalysisSummary

  def self.add_summary(pdf, job, toc)
    add_scatter_plot(pdf, job, toc)
    add_question_statistics_table(pdf, job.exam.questions, toc)
  end

  private

    def self.add_scatter_plot(pdf, job, toc)
      pdf.start_new_page
      section_heading = "Item discrimination by item difficulty plot"
      toc.add(pdf, section_heading)
      pdf.text section_heading, size: 24, style: :bold
      pdf.add_dest(section_heading, pdf.dest_fit_horizontally(pdf.cursor))
      begin
        pdf.svg S3.get(job.scatter_plot_filename, job.id), at: [0, 675]
      rescue => e
        raise "Unable to add scatter plot to PDF: #{e.message}"
      end
    end

    def self.add_question_statistics_table(pdf, questions, toc)
      # put a title on the first page
      pdf.start_new_page
      section_heading = "Item statistics summary table"
      toc.add(pdf, section_heading)
      pdf.text section_heading, size: 24, style: :bold
      pdf.add_dest('item_stats', pdf.dest_fit_horizontally(pdf.cursor))
      pdf.move_down 20

      # create the table
      pdf.bounding_box([100, pdf.cursor], width: 325, height: 600) do
        pdf.table format_questions(questions) do
          row(0).font_style = :bold
          columns(0..3).align = :center
          self.row_colors = ["DDDDDD", "FFFFFF"]
          self.header = true
        end
      end
    end

    def self.format_questions(questions)
      [["Item number", "Difficulty", "Discrimination"]] +
      questions.map do |question|
        [question.number, PdfHelper.round(question.difficulty), 
        PdfHelper.round(question.discrimination)]
      end
    end
end