class Tag < ApplicationRecord
  has_many :teaching_material_tags, dependent: :destroy
  has_many :teaching_materials, through: :teaching_material_tags

  validates :name, presence: true, uniqueness: true

  before_save :normalize_name

  private

  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end
