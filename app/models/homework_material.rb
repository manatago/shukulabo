class HomeworkMaterial < ApplicationRecord
  belongs_to :homework
  belongs_to :teaching_material

  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  # デフォルトのスコープとして position でソート
  default_scope { order(:position) }

  # 新しい教材を追加する際に、自動的に最後の position を設定
  before_validation :set_position, on: :create

  private

  def set_position
    return if position.present?
    last_position = homework.homework_materials.maximum(:position) || -1
    self.position = last_position + 1
  end
end
