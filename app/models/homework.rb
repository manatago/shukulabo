class Homework < ApplicationRecord
  belongs_to :account_group
  belongs_to :user # 作成者（教師）

  has_many :homework_materials, -> { order(:position) }, dependent: :destroy
  has_many :teaching_materials, through: :homework_materials
  has_many :homework_answers, dependent: :destroy

  validates :title, presence: true
  validates :deadline, presence: true
  validates :account_group_id, presence: true
  validate :deadline_must_be_future

  # 未回答の宿題かどうかを判定
  def unanswered_by?(user)
    homework_answers.where(user: user).empty?
  end

  # 期限切れかどうかを判定
  def expired?
    deadline < Time.current
  end

  # 回答期限までの残り時間を計算
  def remaining_time
    return 0 if expired?
    ((deadline - Time.current) / 1.hour).round(1)
  end

  private

  def deadline_must_be_future
    return unless deadline
    
    if deadline <= Time.current
      errors.add(:deadline, "は現在時刻より後に設定してください")
    end
  end
end
