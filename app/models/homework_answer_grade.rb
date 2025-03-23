class HomeworkAnswerGrade < ApplicationRecord
  belongs_to :homework_answer
  belongs_to :teaching_material

  validates :homework_answer_id, uniqueness: { scope: :teaching_material_id }
  validates :score, inclusion: { in: 0..2, allow_nil: true }

  # 採点結果の定数
  SCORES = {
    bad: 0,    # ×
    fair: 1,   # △
    good: 2    # ○
  }.freeze

  # 採点結果を文字列で返す
  def score_label
    case score
    when SCORES[:good] then "○"
    when SCORES[:fair] then "△"
    when SCORES[:bad] then "×"
    else "未採点"
    end
  end
end
