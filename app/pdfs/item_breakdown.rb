class ItemBreakdown
  def self.add_item_breakdowns(pdf, job, toc)
    pdf.start_new_page
    section_heading = "Item details"
    toc.add(pdf, section_heading)
    pdf.text section_heading, size: 24, style: :bold
    pdf.move_down 10

    job.exam.questions.each_with_index do |question, index|
      pdf.start_new_page unless index == 0
      add_item_breakdown(pdf, question, toc, job)
    end
  end

  private
    def self.add_item_breakdown(pdf, question, toc, job)
      question_heading = add_header(pdf, question, toc)
      key = find_answer(question.distractors)
      add_subheader(pdf, key, question.difficulty, question.discrimination)
      add_item_details(pdf, question)
      add_group_and_expected_score_titles(pdf)
      add_group_breakdowns(pdf, question.distractors)
      if Settings.RUN_MIRT?
        add_expected_score(pdf, question.number, job)
      end
    end

    def self.add_item_details(pdf, question)
      pdf.move_down 10
      pdf.text "Standard deviation: #{PdfHelper.round question.std_dev }", size: 14
      pdf.text "Correlation with total test score: #{PdfHelper.round question.correlation }", size: 14
      pdf.text "Correlation with total test score (scored without item): #{PdfHelper.round question.correlation_woi }", size: 14
      pdf.text "Reliability index: #{PdfHelper.round question.reliability }", size: 14
      pdf.text "Reliability index (scored without item): #{PdfHelper.round question.reliability_woi }", size: 14
      pdf.text "Validity index: #{PdfHelper.round question.validity }", size: 14
    end

    def self.add_group_and_expected_score_titles(pdf)
      pdf.move_down 20
      title = "Group breakdowns"
      if Settings.RUN_MIRT?
        title = "#{title}#{Prawn::Text::NBSP * 47}Expected score versus ability"
      end
      pdf.text title, size: 14, style: :bold
    end

    def self.find_answer(distractors)
      key = "N/A"
      distractors.each do |distractor|
        if distractor.correct == true
          key = distractor.label
        end
      end
      key
    end

    def self.add_expected_score(pdf, question_number, job)
        if question_number == 1 
          y_placement = 480
        else
          y_placement = 520
        end
      begin
        pdf.svg S3.get(job.expected_filename(question_number), job.id), at: [250, y_placement], width: 300, height: 300
      rescue => e
        raise "Unable to add expected score plot to PDF: #{e.message}"
      end
    end

    def self.add_group_breakdowns(pdf, distractors)
      pdf.move_down 10
      pdf.table format_distractors(distractors) do
        row(0).font_style = :bold
        columns(0..3).align = :center
        self.row_colors = ["DDDDDD", "FFFFFF"]
        self.header = true
      end
    end

    def self.format_distractors(distractors)
      [["Distractor", "Total", "Top", "Mid", "Low"]] +
      distractors.map do |distractor|
        [distractor.label, distractor.total, distractor.hi, distractor.mid, distractor.lo]
      end
    end

    def self.add_header(pdf, question, toc)
      question_heading = "Item #{question.number}"
      toc.add(pdf, question_heading, :italic, 4)
      pdf.text question_heading, size: 21, style: :bold_italic
      question_heading
    end

    def self.add_subheader(pdf, key, difficulty, discrimination)
      pdf.move_down 10
      sub_header = "Key = #{key}, Difficulty = " +
        "#{PdfHelper.round(difficulty)}, Discrimination (CPBR) = " +
        "#{PdfHelper.round(discrimination)}"
      pdf.text sub_header, size: 14, style: :bold
    end
end