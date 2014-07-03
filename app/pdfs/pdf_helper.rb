class PdfHelper

  def self.create_new_pdf_document(title, author, subject)
    Prawn::Document.new(
      info: { 
        Title: 'Product Name - Item Analysis Report',
        Author: 'Product Name',
        Subject: 'Item Analysis Report',
        Creator: 'Product Name',
        CreationDate: Time.now.utc
      }
    )
  end

  def self.add_page_numbers(pdf)
    page_number_string = 'page <page> of <total>'
    options = {
      at: [pdf.bounds.right - 175, 9], 
      width: 150, 
      align: :right, 
      size: 8,
      page_filter: lambda { |pg| pg > 1 }, 
      start_count_at: 2,
    }
    pdf.number_pages(page_number_string, options)
  end

  def self.add_footer(pdf)
    pdf.stroke_color 'cdc9c9'
    pdf.repeat (lambda { |pg| pg > 1 }) do
      pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 15], :width  => pdf.bounds.width do
        pdf.stroke_horizontal_rule
        pdf.move_down(5)
        pdf.text "Created by <u><color rgb='191970'>https://www.example.com</color></u>", 
          size: 8, 
          indent_paragraphs: 5, 
          inline_format: true
      end
    end
  end

  def self.round(value)
    if !value.nil? && valid_float?(value)
     sprintf('%.3f', value) 
    else
      value
    end
  end

  private 

  def self.valid_float?(value)
    !!Float(value) rescue false
  end
end