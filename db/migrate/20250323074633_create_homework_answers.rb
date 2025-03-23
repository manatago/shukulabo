class CreateHomeworkAnswers < ActiveRecord::Migration[7.2]
  def change
    create_table :homework_answers do |t|
      t.references :homework, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :answer_text

      t.timestamps
    end
  end
end
