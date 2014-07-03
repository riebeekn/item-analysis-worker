class Histogram
  def self.add_histogram(pdf, job, toc)
    pdf.start_new_page
    section_heading = "Histogram of test total score"
    toc.add(pdf, section_heading)
    pdf.text section_heading, size: 24, style: :bold

    pdf.move_down 10
    pdf.text "Examinee count: #{job.exam.examinee_count}   " +
      "Mean: #{PdfHelper.round(job.exam.mean)}   " +
      "Standard deviation: #{PdfHelper.round(job.exam.std_dev)}", style: :bold, size: 14

    pdf.add_dest('histogram', pdf.dest_fit_horizontally(pdf.cursor))
    begin
      pdf.svg S3.get(job.histogram_filename, job.id), at: [0, 650]
    rescue => e
      raise "Unable to add histogram to PDF: #{e.message}"
    end
  end
end