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
  validate :must_have_materials

  # 指定ユーザーの回答を取得
  def answer_by(user)
    homework_answers.find_by(user: user)
  end

  # 指定ユーザーの提出状態を取得
  def submission_status_for(user)
    answer = answer_by(user)
    return :not_submitted unless answer
    answer.submission_status
  end

  # 提出状態のラベルを返す
  def submission_status_label_for(user)
    case submission_status_for(user)
    when :graded then "採点済み"
    when :submitted then "提出済み"
    else "未提出"
    end
  end

  # 提出状態に応じたバッジのクラスを返す
  def submission_status_badge_class_for(user)
    case submission_status_for(user)
    when :graded then "bg-secondary"
    when :submitted then "bg-success"
    else "bg-warning"
    end
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

  def must_have_materials
    # パラメータとして渡されたteaching_material_idsをチェック
    if teaching_material_ids.blank?
      errors.add(:base, "少なくとも1つの問題を選択してください")
    end
  end
end
