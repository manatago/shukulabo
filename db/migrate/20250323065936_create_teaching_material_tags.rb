class CreateTeachingMaterialTags < ActiveRecord::Migration[7.2]
  def change
    create_table :teaching_material_tags do |t|
      t.references :teaching_material, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
