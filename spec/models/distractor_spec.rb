require 'spec_helper'
require './app/models/distractor'
require './app/models/question'

describe Distractor do
  before { @distractor = Distractor.new }

  subject { @distractor }

  it { should respond_to(:label) }
  it { should respond_to(:lo) }
  it { should respond_to(:mid) }
  it { should respond_to(:hi) }
  it { should respond_to(:total) }
  it { should respond_to(:correct) }

  describe ".build_distractors_from_string" do
    before { @distractor_string = test_data }
    
    context "question 1" do
      before do
        @question = Question.new(number = 1)
        questions = []
        questions << @question
        Distractor.build_distractors_from_string(questions, @distractor_string)
      end

      it "should set the question number" do
        @question.number.should eq 1
      end

      it "should have the correct number of distractors" do
        @question.distractors.count.should eq 4
      end

      it "should populate the distractor labels" do
        @question.distractors[0].label.should eq "A"
        @question.distractors[1].label.should eq "B"
        @question.distractors[2].label.should eq "C"
        @question.distractors[3].label.should eq "D"
      end

      it "should populate the correct answer flag" do
        @question.distractors[0].correct.should eq false
        @question.distractors[1].correct.should eq false
        @question.distractors[2].correct.should eq false
        @question.distractors[3].correct.should eq true
      end

      it "should populate the lo count" do
        @question.distractors[0].lo.should eq "11"
        @question.distractors[1].lo.should eq "17"
        @question.distractors[2].lo.should eq "8"
        @question.distractors[3].lo.should eq "9"
      end

      it "should populate the mid count" do
        @question.distractors[0].mid.should eq "6"
        @question.distractors[1].mid.should eq "3"
        @question.distractors[2].mid.should eq "4"
        @question.distractors[3].mid.should eq "16"
      end

      it "should populate the hi count" do
        @question.distractors[0].hi.should eq "2"
        @question.distractors[1].hi.should eq "1"
        @question.distractors[2].hi.should eq "3"
        @question.distractors[3].hi.should eq "23"
      end

      it "should populate the total count" do
        @question.distractors[0].total.should eq 19
        @question.distractors[1].total.should eq 21
        @question.distractors[2].total.should eq 15
        @question.distractors[3].total.should eq 48
      end
    end

    context "question 54" do
      before do
        @question = Question.new(number = 54)
        questions = []
        questions << @question
        Distractor.build_distractors_from_string(questions, @distractor_string)
      end

      it "should set the question number" do
        @question.number.should eq 54
      end

      it "should have the correct number of distractors" do
        @question.distractors.count.should eq 3
      end

      it "should populate the distractor labels" do
        @question.distractors[0].label.should eq "A"
        @question.distractors[1].label.should eq "C"
        @question.distractors[2].label.should eq "D"
      end

      it "should populate the correct answer flag" do
        @question.distractors[0].correct.should eq false
        @question.distractors[1].correct.should eq true
        @question.distractors[2].correct.should eq false
      end

      it "should populate the lo count" do
        @question.distractors[0].lo.should eq "15"
        @question.distractors[1].lo.should eq "10"
        @question.distractors[2].lo.should eq "8"
      end

      it "should populate the mid count" do
        @question.distractors[0].mid.should eq "1"
        @question.distractors[1].mid.should eq "21"
        @question.distractors[2].mid.should eq "3"
      end

      it "should populate the hi count" do
        @question.distractors[0].hi.should eq "5"
        @question.distractors[1].hi.should eq "22"
        @question.distractors[2].hi.should eq "0"
      end
    end

    context "question 32456" do
      before do
        @question = Question.new(number = 32456)
        questions = []
        questions << @question
        Distractor.build_distractors_from_string(questions, @distractor_string)
      end

      it "should set the question number" do
        @question.number.should eq 32456
      end

      it "should have the correct number of distractors" do
        @question.distractors.count.should eq 2
      end

      it "should populate the distractor labels" do
        @question.distractors[0].label.should eq "A"
        @question.distractors[1].label.should eq "D"
      end

      it "should populate the correct answer flag" do
        @question.distractors[0].correct.should eq true
        @question.distractors[1].correct.should eq false
      end

      it "should populate the low count" do
        @question.distractors[0].lo.should eq "17"
        @question.distractors[1].lo.should eq "10"
      end

      it "should populate the mid count" do
        @question.distractors[0].mid.should eq "18"
        @question.distractors[1].mid.should eq "5"
      end

      it "should populate the hi count" do
        @question.distractors[0].hi.should eq "20"
        @question.distractors[1].hi.should eq "1"
      end
    end

    context "all questions" do
      before do
        question_1 = Question.new(number = 1)
        question_54 = Question.new(number = 54)
        question_32456 = Question.new(number = 32456)
        @questions = []
        @questions << question_1
        @questions << question_54
        @questions << question_32456
        Distractor.build_distractors_from_string(@questions, @distractor_string)
      end

      it "should set the question numbers" do
        @questions[0].number.should eq 1
        @questions[1].number.should eq 54
        @questions[2].number.should eq 32456
      end

      it "should have the correct number of distractors for each question" do
        @questions[0].distractors.count.should eq 4
        @questions[1].distractors.count.should eq 3
        @questions[2].distractors.count.should eq 2
      end
    end
  end

  private

  def test_data
    "\"\",\"response\",\"score.level\",\"Freq\"
     \"item_ 1.1\",\" A\",\"lower\",11
     \"item_ 1.2\",\" B\",\"lower\",17
     \"item_ 1.3\",\" C\",\"lower\",8
     \"item_ 1.4\",\"*D\",\"lower\",9
     \"item_ 1.5\",\" A\",\"middle\",6
     \"item_ 1.6\",\" B\",\"middle\",3
     \"item_ 1.7\",\" C\",\"middle\",4
     \"item_ 1.8\",\"*D\",\"middle\",16
     \"item_ 1.9\",\" A\",\"upper\",2
     \"item_ 1.10\",\" B\",\"upper\",1
     \"item_ 1.11\",\" C\",\"upper\",3
     \"item_ 1.12\",\"*D\",\"upper\",23
     \"item_ 54.1\",\" A\",\"lower\",15
     \"item_ 54.2\",\"*C\",\"lower\",10
     \"item_ 54.3\",\" D\",\"lower\",8
     \"item_ 54.4\",\" A\",\"middle\",1
     \"item_ 54.5\",\"*C\",\"middle\",21
     \"item_ 54.6\",\" D\",\"middle\",3
     \"item_ 54.7\",\" A\",\"upper\",5
     \"item_ 54.8\",\"*C\",\"upper\",22
     \"item_ 54.9\",\" D\",\"upper\",0
     \"item_ 32456.1\",\"*A\",\"lower\",17
     \"item_ 32456.2\",\" D\",\"lower\",10
     \"item_ 32456.3\",\"*A\",\"middle\",18
     \"item_ 32456.4\",\" D\",\"middle\",5
     \"item_ 32456.5\",\"*A\",\"upper\",20
     \"item_ 32456.6\",\" D\",\"upper\",1"
  end
end