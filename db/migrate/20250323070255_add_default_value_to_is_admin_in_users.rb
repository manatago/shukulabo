class AddDefaultValueToIsAdminInUsers < ActiveRecord::Migration[7.2]
  def up
    change_column_default :users, :is_admin, false
    # 既存のレコードのNULLをfalseに更新
    User.where(is_admin: nil).update_all(is_admin: false)
  end

  def down
    change_column_default :users, :is_admin, nil
  end
end
