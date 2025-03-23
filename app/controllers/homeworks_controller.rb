class HomeworksController < Admin::BaseController
  before_action :set_homework, only: [:show, :edit, :update, :destroy]

  def index
    @homeworks = current_user.homeworks.includes(:account_group, :teaching_materials)
                           .order(deadline: :desc)
  end

  def show
    @answers = @homework.homework_answers.includes(:user)
  end

  def new
    @homework = current_user.homeworks.build
    @account_groups = AccountGroup.all
    @available_materials = TeachingMaterial.where(user: current_user).order(created_at: :desc)
  end

  def edit
    @account_groups = AccountGroup.all
    @available_materials = TeachingMaterial.where(user: current_user).order(created_at: :desc)
  end

  def create
    @homework = current_user.homeworks.build(homework_params)

    if @homework.save
      create_homework_materials
      redirect_to @homework, notice: t('notices.created', model: Homework.model_name.human)
    else
      @account_groups = AccountGroup.all
      @available_materials = TeachingMaterial.where(user: current_user).order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @homework.update(homework_params)
      @homework.homework_materials.destroy_all
      create_homework_materials
      redirect_to @homework, notice: t('notices.updated', model: Homework.model_name.human)
    else
      @account_groups = AccountGroup.all
      @available_materials = TeachingMaterial.where(user: current_user).order(created_at: :desc)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @homework.destroy
    redirect_to homeworks_url, notice: t('notices.deleted', model: Homework.model_name.human)
  end

  private

  def set_homework
    @homework = current_user.homeworks.find(params[:id])
  end

  def homework_params
    params.require(:homework).permit(:title, :deadline, :account_group_id)
  end

  def create_homework_materials
    return unless params[:teaching_material_ids]

    params[:teaching_material_ids].each_with_index do |material_id, index|
      @homework.homework_materials.create!(
        teaching_material_id: material_id,
        position: index
      )
    end
  end
end