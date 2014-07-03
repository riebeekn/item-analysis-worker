require 'spec_helper'
require './app/pdfs/pdf_helper'

describe PdfHelper do
  describe ".round" do
    it "should round valid string float values to 3 decimal places" do
      PdfHelper.round("1.23").should eq "1.230"
      PdfHelper.round("123.456789").should eq "123.457"
    end

    it "should round valid float values to 3 decimal places" do
      PdfHelper.round(1.23).should eq "1.230"
      PdfHelper.round(123.456789).should eq "123.457"
    end

    it "should round integer values to 3 decimal places" do
      PdfHelper.round(3).should eq "3.000"
    end

    it "should not return orginal value when not valid float value" do
      PdfHelper.round("asdf").should eq "asdf"
    end
  end
end