class TeachingMaterialTag < ApplicationRecord
  belongs_to :teaching_material
  belongs_to :tag

  validates :teaching_material_id, uniqueness: { scope: :tag_id }
end
