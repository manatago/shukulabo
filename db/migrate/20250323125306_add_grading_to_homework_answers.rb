class AddGradingToHomeworkAnswers < ActiveRecord::Migration[7.2]
  def change
    add_column :homework_answers, :score, :integer, comment: '採点結果（0: ×, 1: △, 2: ○）'
    add_column :homework_answers, :comment, :text, comment: '採点コメント'
    add_column :homework_answers, :repeat, :boolean, null: false, default: false, comment: 'リピート問題フラグ'

    add_index :homework_answers, :score
    add_index :homework_answers, :repeat
  end
end
