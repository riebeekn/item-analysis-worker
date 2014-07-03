require 'spec_helper'
require './app/pdfs/item_analysis_summary'
require './app/models/question'
require './app/models/job'
require './app/pdfs/pdf_helper'

describe ItemAnalysisSummary do
  describe ".format_questions" do
    before do
      questions = []
      questions << Question.new(1, 1, 0.678, 1.244)
      questions << Question.new(2, 1, 0.933, 1.453)
      @questions_formatted_for_pdf = ItemAnalysisSummary.format_questions(questions)
    end

    it "should format the questions for pdf consumption" do
      @questions_formatted_for_pdf[0][0].should eq "Item number"
      @questions_formatted_for_pdf[0][1].should eq "Difficulty"
      @questions_formatted_for_pdf[0][2].should eq "Discrimination"
      @questions_formatted_for_pdf[1][0].should eq 1
      @questions_formatted_for_pdf[1][1].should eq "0.678"
      @questions_formatted_for_pdf[1][2].should eq "1.244"
      @questions_formatted_for_pdf[2][0].should eq 2
      @questions_formatted_for_pdf[2][1].should eq "0.933"
      @questions_formatted_for_pdf[2][2].should eq "1.453"
    end    
  end
end