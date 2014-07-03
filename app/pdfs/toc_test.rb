require 'prawn'
require './app/pdfs/toc'

class TocTest
  def self.create
    @toc = Toc.new
    @current_section_header_number = 0 # used to fake up section header's
    pdf = Prawn::Document.new

    add_title_page(pdf)
    add_a_content_page_with_3_sections(pdf)
    250.times { add_a_content_page(pdf) }

    fill_in_toc(pdf)

    add_page_numbers(pdf)

    pdf.render_file './output/test.pdf'
  end

  def self.add_title_page(pdf)
    pdf.move_down 200
    pdf.text "This is my title page", size: 38, style: :bold, align: :center
  end

  def self.test_some_shit(pdf)
    pdf.start_new_page
    pdf.text_box "." * 200, at: [0, pdf.cursor], overflow: :shrink_to_fit
    pdf.move_down 30

    string = "This is the beginning of the text. It will be cut somewhere and " + 
      "the rest of the text will procede to be rendered this time by " + 
      "calling another method." + 
      " . " * 50
    y_position = pdf.cursor - 20 
    excess_text = pdf.text_box string,
                    width: 300, 
                    height:  25,
                    overflow: :truncate,
                    at: [100, y_position],
                    size: 18
    pdf.text_box excess_text, 
      width:300,
            at: [100, y_position-100]

    pdf.stroke do
      pdf.horizontal_line 200,500
    end

    pdf.move_down 20
    stroke_dashed_horizontal_line pdf,200,500
  end

   def self.stroke_dashed_horizontal_line(pdf, x1,x2,options={})
    options = options.dup
    line_length = options.delete(:line_length) || 0.5
    space_length = options.delete(:space_length) || line_length
    period_length = line_length + space_length
    total_length = x2 - x1
 
    (total_length/period_length).ceil.times do |i|
      left_bound = x1 + i * period_length
      pdf.stroke_horizontal_line(left_bound, left_bound + line_length, options)
    end
  end

  def self.fill_in_toc(pdf)
    pdf.go_to_page(1)

    test_some_shit(pdf)

    pdf.start_new_page
    pdf.text "Table of Contents", size: 24, align: :center, style: :bold
    pdf.move_down 20

    number_of_toc_entries_per_page = 40
    offset = (@toc.items.count.to_f / number_of_toc_entries_per_page).ceil
    @toc.items.each_with_index do |toc_item, index| 
      if index % number_of_toc_entries_per_page == 0 && index != 0
        pdf.start_new_page 
        pdf.move_down 20
      end
      pdf.float do
        pdf.text "#{toc_item.text}#{'.' * 10} page #{toc_item.page + offset}", align: :left, size: 14
      end
      pdf.text "#{toc_item.page + offset}", align: :right, size: 14
    end
  end

  def self.add_a_content_page_with_3_sections(pdf)
    pdf.start_new_page
    toc_heading = grab_some_section_header_text

    @toc.add(pdf.page_count, toc_heading)

    pdf.text toc_heading, size: 38, style: :bold
    pdf.text "Here is the content for this section"

    @toc.add(pdf.page_count, "#{toc_heading} - a")

    pdf.text "#{toc_heading} - a", size: 34, style: :bold
    pdf.text "Here is the content for this section"

    @toc.add(pdf.page_count, "#{toc_heading} - b")

    pdf.text "#{toc_heading} - b", size: 38, style: :bold
    pdf.text "Here is the content for this section"    
    
  end

  def self.add_a_content_page(pdf)
    pdf.start_new_page
    toc_heading = grab_some_section_header_text

    @toc.add(pdf.page_count, toc_heading)

    pdf.text toc_heading, size: 38, style: :bold
    pdf.text "Here is the content for this section"
    # randomly span a section over 2 pages
    if [true, false].sample
      pdf.start_new_page
      pdf.text "The content for this section spans 2 pages"
    end
  end

  def self.add_page_numbers(pdf)
    page_number_string = 'page <page> of <total>'
    options = {
      at: [pdf.bounds.right - 175, 9], 
      width: 150, 
      align: :right, 
      size: 10,
      page_filter: lambda { |pg| pg > 1 }, 
      start_count_at: 2,
    }
    pdf.number_pages(page_number_string, options)
  end

  def self.grab_some_section_header_text
    "Section #{@current_section_header_number += 1}"
  end
end