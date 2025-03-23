class CreateHomeworkAnswerGrades < ActiveRecord::Migration[7.2]
  def change
    create_table :homework_answer_grades do |t|
      t.references :homework_answer, null: false, foreign_key: true, comment: '採点対象の回答'
      t.references :teaching_material, null: false, foreign_key: true, comment: '採点対象の問題'
      t.integer :score, comment: '採点結果（0: ×, 1: △, 2: ○）'
      t.text :comment, comment: '採点コメント'
      t.boolean :repeat, null: false, default: false, comment: 'リピート問題フラグ'

      t.timestamps

      t.index [:homework_answer_id, :teaching_material_id], unique: true, name: 'idx_unique_grade'
    end
  end
end
