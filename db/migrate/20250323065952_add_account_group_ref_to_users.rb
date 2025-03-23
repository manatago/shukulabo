class AddAccountGroupRefToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :account_group, null: false, foreign_key: true
  end
end
