class Question 
  attr_accessor :number, :difficulty, :discrimination, :reliability, 
                :distractors, :std_dev, :correlation, :correlation_woi,
                :reliability_woi, :validity

  def initialize(number = nil, std_dev = nil, difficulty = nil, discrimination = nil,
    reliability = nil, reliability_woi = nil, correlation = nil, 
    correlation_woi = nil, validity = nil)
    @number = number
    @std_dev = std_dev
    @difficulty = difficulty
    @discrimination = discrimination
    @reliability = reliability
    @reliability_woi = reliability_woi
    @correlation = correlation
    @correlation_woi = correlation_woi
    @validity = validity
    @distractors = []
  end

  def self.build_questions_from_string(question_string)
    question_array = question_string.split("\n")
    
    questions = []
    question_array.each.with_index do |current_line, index|
      next if index == 0
      questions << build_from_line(current_line, index)
    end

    questions
  end

  private
    def self.build_from_line(line, index)
      split_line = line.split(",")
      Question.new(number = index, 
                   std_dev = split_line[1],         # index 1 is std_dev
                   difficulty = split_line[4],      # index 4 is difficulty
                   discrimination = split_line[5],  # index 5 is discrimination
                   reliability = split_line[7],     # index 7 is reliability
                   reliability_woi = split_line[8], # index 8 is reliability woi
                   correlation = split_line[2],     # index 2 is correlation
                   correlation_woi = split_line[3], # index 3 is correlation woi  
                   validity = split_line[9])        # index 9 is validity
    end
end