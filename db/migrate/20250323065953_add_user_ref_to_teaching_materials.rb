class AddUserRefToTeachingMaterials < ActiveRecord::Migration[7.2]
  def change
    add_reference :teaching_materials, :user, null: false, foreign_key: true
  end
end
