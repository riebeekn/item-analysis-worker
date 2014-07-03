require 'prawn'
require 'prawn/table'
require 'prawn-svg'
require './app/services/s3'
require './app/pdfs/toc'
require './app/pdfs/pdf_helper'
require './app/pdfs/histogram'
require './app/pdfs/item_analysis_summary'
require './app/pdfs/item_breakdown'

# class to create the IA PDF
class ItemAnalysisPdf
  # method used to create the PDF
  def self.create(job)
    toc = Toc.new
    pdf = PdfHelper.create_new_pdf_document(
      'Product Name - Item Analysis Report',
      'Product Name',
      'Item Analysis Report')
    add_title_page(pdf, job)

    # add the content sections
    # summary section
    Histogram.add_histogram(pdf, job, toc)

    # item analysis summary section
    ItemAnalysisSummary.add_summary(pdf, job, toc)
    
    # item detail section
    ItemBreakdown.add_item_breakdowns(pdf, job, toc)

    # add reference content
    Toc.add_table_of_contents(pdf, toc)
    PdfHelper.add_page_numbers(pdf)
    PdfHelper.add_footer(pdf)

    # finally render the pdf file
    pdf.render_file job.pdf_filename
  end

  private

    def self.add_title_page(pdf, job)
      pdf.move_down 200
      pdf.text 'Product Name', size: 36, align: :center
      pdf.text 'Item Analysis Report', size: 24, align: :center
      pdf.text "Date submitted - #{job.job_start.strftime('%Y-%m-%d %H:%M:%S')}", align: :center
      pdf.text "Date completed - #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}", align: :center
      pdf.text "Number of examinees - #{job.exam.examinee_count}", align: :center
      pdf.text "Number of items - #{job.exam.questions.count}", align: :center
    end
end