class TeachingMaterial < ApplicationRecord
  belongs_to :user
  has_many :teaching_material_tags, dependent: :destroy
  has_many :tags, through: :teaching_material_tags
  
  has_many :homework_materials, dependent: :destroy
  has_many :homeworks, through: :homework_materials

  has_one_attached :question_image
  has_one_attached :answer_image

  validates :title, presence: true
  validate :has_question_content

  private

  def has_question_content
    unless question_text.present? || question_image.attached?
      errors.add(:base, "問題の内容（テキストまたは画像）を入力してください")
    end
  end
end
