class CreateHomeworks < ActiveRecord::Migration[7.2]
  def change
    create_table :homeworks do |t|
      t.string :title
      t.datetime :deadline
      t.references :account_group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
