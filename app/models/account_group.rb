class AccountGroup < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :homeworks, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # グループに所属する生徒のカウント
  def student_count
    users.where(is_admin: false).count
  end

  # 期限内の宿題のカウント
  def active_homework_count
    homeworks.where('deadline > ?', Time.current).count
  end
end
