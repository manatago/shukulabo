class CreateTeachingMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :teaching_materials do |t|
      t.string :title
      t.text :question_text
      t.text :answer_text

      t.timestamps
    end
  end
end
