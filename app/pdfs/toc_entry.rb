class TocEntry
  attr_accessor :page, :text, :style

  def initialize(page, text, style)
    @page = page
    @text = text
    @style = style
  end
end