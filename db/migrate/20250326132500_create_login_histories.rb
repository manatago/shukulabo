class CreateLoginHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :login_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
    
    add_index :login_histories, :created_at
  end
end