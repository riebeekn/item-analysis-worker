class Distractor 

  attr_accessor :label, :lo, :mid, :hi, :correct

  def self.LO
    "lower"
  end

  def self.MID
    "middle"
  end

  def self.HI
    "upper"
  end

  def initialize(label = nil, correct = false,
    lo = 0, mid = 0, hi = 0)
    @label = label
    @correct = correct
    @lo = lo
    @mid = mid
    @hi = hi
  end

  def total
    lo.to_i + mid.to_i + hi.to_i
  end

  def self.build_distractors_from_string(questions, distractor_string)
    distractor_array = distractor_string.split("\n")

    distractor_array.each.with_index do |current_line, index|
      next if index == 0
      build_from_line(current_line, questions)
    end
  end

  def self.build_from_line(line, questions)
    split_line = line.split(",")
    match = /item_ (?<q_no>\d+).*/.match(split_line[0])
    question_current_line_refers_to = match["q_no"]

    questions.each do |question|
      if question.number == question_current_line_refers_to.to_i
        # set the label
        current_distractor_label = set_label(split_line)
        
        # check correct / incorrect status
        is_correct = current_distractor_label.include? "*"
        current_distractor_label.gsub! "*", ""

        # set the current group
        current_distractor_group = set_distractor_group(split_line)
        
        # check if is a new distractor or not
        is_new_distractor = true
        question.distractors.each do |existing_distractor|
          if existing_distractor.label == current_distractor_label
            is_new_distractor = false
            
            # set the appropriate group count
            set_appropriate_group_count(existing_distractor, split_line, 
              current_distractor_group)
          end
        end

        # if not add a new one
        if is_new_distractor
          # create the new distractor
          new_distractor = Distractor.new(
            distractor_label = current_distractor_label,
            correct = is_correct
          )

          # set the appropriate group count
          set_appropriate_group_count(new_distractor, split_line, 
            current_distractor_group)

          # add the distractor
          question.distractors << new_distractor
        end
      end
    end
  end

  private 

    def self.set_distractor_group(split_line)
      group_item = split_line[2]
      distractor_group = Distractor.HI
      if group_item.include? Distractor.LO
        distractor_group = Distractor.LO
      elsif group_item.include? Distractor.MID
        distractor_group = Distractor.MID
      end

      distractor_group
    end

    def self.set_label(split_line)
      distractor_label = split_line[1]
      distractor_label.gsub! /"/, ''
      distractor_label.strip!
      distractor_label
    end

    def self.set_appropriate_group_count(distractor, split_line, group)
      if group == Distractor.LO
        distractor.lo = split_line[3]
      elsif group == Distractor.MID
        distractor.mid = split_line[3]
      elsif group == Distractor.HI
        distractor.hi = split_line[3]
      end
    end
end