require './app/pdfs/toc_entry'

class Toc
  attr_accessor :items

  def initialize
    @items = []
  end

  def add(pdf, text, style = :bold, leading = 0)
    toc_text = "#{'.' * leading}#{text}"
    pdf.add_dest(toc_text, pdf.dest_fit_horizontally(pdf.cursor))
    @items << TocEntry.new(pdf.page_count, toc_text, style)
  end

  def self.add_table_of_contents(pdf, toc)
    pdf.go_to_page(1)
    pdf.start_new_page
    pdf.text "Table of Contents", size: 36, align: :center, style: :bold
    pdf.move_down 20

    number_of_toc_entries_per_page = 40
    offset = (toc.items.count.to_f / number_of_toc_entries_per_page).ceil
    toc.items.each_with_index do |toc_entry, index| 
      if index % number_of_toc_entries_per_page == 0 && index != 0
        pdf.start_new_page 
        pdf.move_down 20
      end
      pdf.float do
        pdf.text "<link anchor='#{toc_entry.text}'>#{toc_entry.text}</link>", 
          align: :left, size: 14, style: toc_entry.style, inline_format: true
      end
      pdf.text "page #{toc_entry.page + offset}", align: :right, size: 14, style: toc_entry.style
    end
  end
end