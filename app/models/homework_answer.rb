class HomeworkAnswer < ApplicationRecord
  belongs_to :homework
  belongs_to :user

  has_many_attached :images

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
