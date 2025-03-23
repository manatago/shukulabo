class HomeworkAnswer < ApplicationRecord
  belongs_to :homework
  belongs_to :user

  has_many_attached :images
  has_many :grades, class_name: 'HomeworkAnswerGrade', dependent: :destroy
  has_many :graded_materials, through: :grades, source: :teaching_material

  validates :user_id, uniqueness: { scope: :homework_id, message: "は既にこの宿題に回答しています" }
  validates :answer_text, presence: true, unless: :images_attached?
  validate :images_attached_if_no_text
  validate :validate_image_types

  # 回答が提出された日時を返す
  def submitted_at
    created_at
  end

  # 期限内に提出されたかどうかを判定
  def submitted_on_time?
    created_at <= homework.deadline
  end

  # 問題ごとの採点結果を取得する
  def grade_for(teaching_material)
    grades.find_by(teaching_material: teaching_material)
  end

  # 全ての問題の採点が完了しているかを判定
  def fully_graded?
    homework.teaching_materials.all? { |material| grade_for(material).present? }
  end

  # 提出状態を返す（未提出/提出済み/採点済み）
  def submission_status
    return :not_submitted unless persisted?
    return :graded if fully_graded?
    :submitted
  end

  # 提出状態のラベルを返す
  def submission_status_label
    case submission_status
    when :graded then "採点済み"
    when :submitted then "提出済み"
    else "未提出"
    end
  end

  # 提出状態に応じたバッジのクラスを返す
  def submission_status_badge_class
    case submission_status
    when :graded then "bg-secondary"
    when :submitted then "bg-success"
    else "bg-warning"
    end
  end

  # 採点済みの問題数を返す
  def graded_count
    grades.count
  end

  # リピートが必要な問題を返す
  def repeat_materials
    grades.where(repeat: true).map(&:teaching_material)
  end

  private

  def images_attached?
    images.attached?
  end

  def images_attached_if_no_text
    if !answer_text.present? && !images_attached?
      errors.add(:base, "テキストまたは画像による回答が必要です")
    end
  end

  def validate_image_types
    images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/png image/gif])
        errors.add(:images, "はJPEG、PNG、GIF形式のみ許可されています")
      end
    end
  end
end
