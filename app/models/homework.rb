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

  # 生徒グループ名と期限から自動的にタイトルを生成
  def self.generate_title(account_group_name, deadline)
    return nil if account_group_name.blank? || deadline.blank?
    time_str = deadline.strftime('%Y-%m-%d_%H-%M-%S')
    "#{account_group_name}_#{time_str}"
  end

  # 特定の生徒グループのリピート対象の問題を取得
  def self.repeat_materials_for_group(account_group)
    # 生徒グループの宿題を取得
    homework_ids = Homework.where(account_group: account_group).pluck(:id)
    answers = HomeworkAnswer.where(homework_id: homework_ids)
    
    # 各回答からリピート対象の問題とその宿題の情報を取得
    repeat_info = HomeworkAnswerGrade.where(homework_answer: answers, repeat: true)
      .joins(homework_answer: :homework)
      .select('homework_answer_grades.teaching_material_id',
              'homeworks.deadline as homework_deadline',
              'homeworks.id as homework_id')
      .order('homeworks.deadline DESC')
    
    # 重複する教材は最新の宿題の情報を使用
    material_info = repeat_info.group_by(&:teaching_material_id)
      .transform_values { |grades| grades.first }
    
    # 教材と日付情報をまとめて返す
    material_ids = material_info.keys
    materials = TeachingMaterial.where(id: material_ids)
    
    # 教材オブジェクトに日付情報を付加
    materials.each do |material|
      info = material_info[material.id]
      material.instance_variable_set(:@homework_deadline, info.homework_deadline)
      material.instance_eval do
        def homework_deadline
          @homework_deadline
        end
      end
    end
    
    # 出題回数を計算して付加
    materials.each do |material|
      count = Homework.joins(:homework_materials)
                    .where(account_group: account_group)
                    .where(homework_materials: { teaching_material_id: material.id })
                    .count
      material.instance_variable_set(:@assignment_count, count)
      material.instance_eval do
        def assignment_count
          @assignment_count
        end
      end
    end

    materials.sort_by(&:homework_deadline).reverse
  end

  # 特定の生徒グループに過去出題した問題のIDを取得
  def self.previously_assigned_material_ids(account_group)
    joins(:homework_materials)
      .where(account_group: account_group)
      .pluck(Arel.sql('DISTINCT homework_materials.teaching_material_id'))
  end

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
end
