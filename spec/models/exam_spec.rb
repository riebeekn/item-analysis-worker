require 'spec_helper'
require './app/models/exam'

describe Exam do
  before { @exam = Exam.new }

  subject { @exam }

  it { should respond_to(:questions) }
  it { should respond_to(:question_count) }
  it { should respond_to(:examinee_count) }
  it { should respond_to(:mean) }
  it { should respond_to(:std_dev) }

end