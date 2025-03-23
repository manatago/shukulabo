class AddCorrectAnswerToTeachingMaterials < ActiveRecord::Migration[7.2]
  def change
    add_column :teaching_materials, :correct_answer, :text, comment: '問題の正答'
  end
end
