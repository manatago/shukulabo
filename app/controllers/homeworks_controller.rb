class HomeworksController < Admin::BaseController
  before_action :set_homework, only: [:show, :edit, :update, :destroy]

  def index
    @homeworks = current_user.homeworks.includes(:account_group, :teaching_materials)
                           .order(deadline: :desc)
  end

  def show
    @answers = @homework.homework_answers.includes(:user, images_attachments: :blob).order(:created_at)
  end

  def new
    @homework = current_user.homeworks.build
    @account_groups = AccountGroup.all
    @available_materials = TeachingMaterial.where(user: current_user)
    
    # 検索条件の適用
    @available_materials = @available_materials.where('title LIKE ?', "%#{params[:search]}%") if params[:search].present?
    @available_materials = @available_materials.joins(:tags).where(tags: { id: params[:tag_id] }) if params[:tag_id].present?
    
    # 並び順とページネーション
    @available_materials = @available_materials.order(created_at: :desc).page(params[:page]).per(30)
    
    # 全てのタグを取得（フィルター用）
    @tags = Tag.joins(:teaching_material_tags)
              .where(teaching_material_tags: { teaching_material_id: TeachingMaterial.where(user: current_user) })
              .distinct
  end

  def edit
    @account_groups = AccountGroup.all
    @available_materials = TeachingMaterial.where(user: current_user).order(created_at: :desc)
  rescue ActiveRecord::RecordNotFound
    redirect_to homeworks_path, alert: "指定された宿題は存在しないか、アクセス権限がありません"
  end

  def create
    @homework = current_user.homeworks.build(homework_params.except(:teaching_material_ids))
    @homework.teaching_material_ids = params[:teaching_material_ids]

    if @homework.save
      redirect_to @homework, notice: t('notices.created', model: Homework.model_name.human)
    else
      @account_groups = AccountGroup.all
      @available_materials = TeachingMaterial.where(user: current_user)
      
      # 検索条件の適用
      @available_materials = @available_materials.where('title LIKE ?', "%#{params[:search]}%") if params[:search].present?
      @available_materials = @available_materials.joins(:tags).where(tags: { id: params[:tag_id] }) if params[:tag_id].present?
      
      # 並び順とページネーション
      @available_materials = @available_materials.order(created_at: :desc).page(params[:page]).per(30)
      
      @tags = Tag.joins(:teaching_material_tags)
                .where(teaching_material_tags: { teaching_material_id: TeachingMaterial.where(user: current_user) })
                .distinct
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @homework.assign_attributes(homework_params.except(:teaching_material_ids))
    @homework.teaching_material_ids = params[:teaching_material_ids]

    if @homework.save
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

  def grade_answer
    Rails.logger.debug "Params received: #{params.inspect}"

    @homework = current_user.homeworks.find(params[:id])
    @answer = @homework.homework_answers.find(params[:answer_id])
    @material = TeachingMaterial.find(params[:teaching_material_id])

    @grade = @answer.grades.find_or_initialize_by(teaching_material: @material)

    if @grade.update(grade_params)
      Rails.logger.debug "Grade updated successfully: #{@grade.inspect}"
      flash.now[:notice] = "#{@answer.user.name}さんの回答（問題#{@homework.homework_materials.find_by(teaching_material: @material).position + 1}）を採点しました"
      redirect_to @homework, notice: flash.now[:notice], status: :see_other
    else
      Rails.logger.debug "Grade update failed: #{@grade.errors.full_messages}"
      error_messages = @grade.errors.full_messages.join(", ")
      redirect_to @homework, alert: "採点の保存に失敗しました: #{error_messages}", status: :unprocessable_entity
    end
  end

  private

  def grade_params
    params.require(:grade).permit(:score, :comment, :repeat)
  end

  def set_homework
    @homework = current_user.homeworks.find(params[:id])
  end

  def homework_params
    params.require(:homework).permit(:title, :deadline, :account_group_id, teaching_material_ids: [])
  end
end