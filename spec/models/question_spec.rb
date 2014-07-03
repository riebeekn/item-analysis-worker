require 'spec_helper'
require './app/models/question'

describe Question do
  before { @question = Question.new }

  subject { @question }

  it { should respond_to(:number) }
  it { should respond_to(:difficulty) }
  it { should respond_to(:discrimination) }
  it { should respond_to(:reliability) }
  it { should respond_to(:std_dev) }
  it { should respond_to(:correlation) }
  it { should respond_to(:correlation_woi) }
  it { should respond_to(:reliability_woi) }
  it { should respond_to(:validity) }

  it { should respond_to(:distractors) }

  describe ".initialize" do
    context "no initialize parameters" do
      it "should be populated with default values" do
        @question.number.should be_nil
        @question.difficulty.should be_nil
        @question.discrimination.should be_nil
        @question.reliability.should be_nil
      end
    end

    context "with initialize parameters" do
      it "should be populated with the passed in numbers" do
        question = Question.new(3, 0.65343, 1.345, 3.45, 4.6567, 
          34.2343, 1.234, 8.765, 23.456)

        question.number.should eq 3
        question.std_dev.should eq 0.65343
        question.difficulty.should eq 1.345
        question.discrimination.should eq 3.45
        question.reliability.should eq 4.6567
        question.reliability_woi.should eq 34.2343
        question.correlation.should eq 1.234
        question.correlation_woi.should eq 8.765
        question.validity.should eq 23.456
      end
    end
  end

  describe ".build_questions_from_string" do
    context "when string is empty" do
      it "should return empty" do
        Question.build_questions_from_string("").should be_empty
      end
    end

    context "when string contains questions" do
      it "should build the questions" do
        questions = Question.build_questions_from_string(
"\"\",\"Sample.SD\",\"Item.total\",\"Item.Tot.woi\",\"Difficulty\",\"Discrimination\",\"Item.Criterion\",\"Item.Reliab\",\"Item.Rel.woi\",\"Item.Validity\"
\"1\",0.504006932993731,0.27577705078871,-0.0349312784513503,0.433333333333333,0.1,NA,0.13665735319859,-0.0173096928963166,NA
\"2\",0.508547627715608,0.270539937804316,-0.043193421279068,0.5,0.1,NA,0.135269968902158,-0.021596710639534,NA
\"3\",0.507416263404925,0.269752671429065,-0.0432796357785838,0.533333333333333,0.3,NA,0.134576276753942,-0.0215916758543765,NA
\"4\",0.507416263404925,0.439390949338064,0.14098495165894,0.466666666666667,0.4,NA,0.219206718836318,0.0703356514398187,NA
\"5\",0.508547627715608,0.437026053376203,0.137504774554232,0.5,0.5,NA,0.218513026688102,0.0687523872771158,NA
\"6\",0.507416263404925,0.144609679528983,-0.166282198642108,0.533333333333333,0.3,NA,0.0721439834144843,-0.082956135578434,NA
\"7\",0.504006932993731,0.354170527155044,0.047846325161608,0.566666666666667,0.5,NA,0.175504113498697,0.023709558638634,NA
\"8\",0.490132517853561,0.329647945072941,0.0304805811019681,0.366666666666667,0.4,NA,0.158855501941509,0.0146884216413077,NA
\"9\",0.507416263404925,0.189104965537901,-0.123654060414442,0.466666666666667,0.3,NA,0.0943421321574026,-0.0616894838072386,NA
\"10\",0.479463301485384,0.544471008486084,0.285805121634112,0.666666666666667,0.6,NA,0.256666094839992,0.256666094839992,NA")
        questions.count.should eq 10

        # just check the first and last question
        question_1 = questions[0]
        question_1.number.should eq 1
        question_1.std_dev.should eq 0.504006932993731.to_s
        question_1.correlation.should eq 0.27577705078871.to_s
        question_1.correlation_woi.should eq -0.0349312784513503.to_s
        question_1.difficulty.should eq 0.433333333333333.to_s
        question_1.discrimination.should eq 0.1.to_s
        question_1.reliability.should eq 0.13665735319859.to_s
        question_1.reliability_woi.should eq -0.0173096928963166.to_s
        question_1.validity.should eq 'NA'

        question_10 = questions[9]
        question_10.number.should eq 10
        question_10.std_dev.should eq 0.479463301485384.to_s
        question_10.correlation.should eq 0.544471008486084.to_s
        question_10.correlation_woi.should eq 0.285805121634112.to_s
        question_10.difficulty.should eq 0.666666666666667.to_s
        question_10.discrimination.should eq 0.6.to_s
        question_10.reliability.should eq 0.256666094839992.to_s
        question_10.reliability_woi.should eq 0.256666094839992.to_s
        question_10.validity.should eq 'NA'
      end
    end
  end
end