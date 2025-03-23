class ChangeAccountGroupToNullableInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :account_group_id, true
  end
end
