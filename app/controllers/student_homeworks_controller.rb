class StudentHomeworksController < ApplicationController
  before_action :set_homework, only: [:show, :answer]
  before_action :check_homework_access, only: [:show, :answer]
  before_action :check_deadline, only: [:answer]

  def index
    @homeworks = Homework.where(account_group: current_user.account_group)
                        .includes(:teaching_materials)
                        .order(deadline: :desc)
  end

  def show
    @answer = @homework.homework_answers.find_by(user: current_user)
    @can_answer = !@homework.expired? && @answer.nil?
  end

  def answer
    @answer = @homework.homework_answers.build(answer_params)
    @answer.user = current_user

    if @answer.save
      redirect_to student_homework_path(@homework), notice: "回答を提出しました"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_homework
    @homework = Homework.find(params[:id])
  end

  def check_homework_access
    unless @homework.account_group == current_user.account_group
      redirect_to student_homeworks_path, alert: "アクセス権限がありません"
    end
  end

  def check_deadline
    if @homework.expired?
      redirect_to student_homework_path(@homework), alert: "提出期限が過ぎています"
    end
  end

  def answer_params
    params.require(:homework_answer).permit(:answer_text, images: [])
  end
end