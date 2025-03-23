class CreateHomeworkMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :homework_materials do |t|
      t.references :homework, null: false, foreign_key: true
      t.references :teaching_material, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
