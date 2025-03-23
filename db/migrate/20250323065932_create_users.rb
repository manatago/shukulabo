class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :uid
      t.string :provider
      t.boolean :is_admin

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :uid, unique: true
  end
end
