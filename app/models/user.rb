class User < ApplicationRecord
  belongs_to :account_group, optional: true
  has_many :teaching_materials, dependent: :destroy
  has_many :homeworks, dependent: :destroy
  has_many :homework_answers, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :name, presence: true

  def self.from_omniauth(auth)
    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.email = auth.info.email
    user.name = auth.info.name
    # 最初のユーザーを管理者として設定
    user.is_admin = true if User.count.zero?
    user.save
    user
  end

  def admin?
    is_admin
  end

  # 指定された宿題に対する回答を取得
  def answer_for(homework)
    homework_answers.find_by(homework: homework)
  end

  # 未回答の宿題を取得
  def unanswered_homeworks
    return [] unless account_group
    account_group.homeworks
                .where('deadline > ?', Time.current)
                .where.not(id: homework_answers.select(:homework_id))
                .order(deadline: :asc)
  end
end
