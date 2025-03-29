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
  end

  def edit
    @account_groups = AccountGroup.all

    if params[:basic]
      render :basic_edit
    else
      # 通常の教材一覧（過去に出題した問題を除外）
      previously_assigned_ids = Homework.previously_assigned_material_ids(@homework.account_group)
      @available_materials = TeachingMaterial.where(user: current_user)
                                           .where.not(id: previously_assigned_ids)
      
      # 検索条件の適用
      @available_materials = @available_materials.where('title LIKE ?', "%#{params[:search]}%") if params[:search].present?
      @available_materials = @available_materials.joins(:tags).where(tags: { id: params[:tag_id] }) if params[:tag_id].present?
      
      # 並び順とページネーション
      @available_materials = @available_materials.order(created_at: :desc).page(params[:page]).per(30)
      
      # 全てのタグを取得（フィルター用）
      @tags = Tag.joins(:teaching_material_tags)
                .where(teaching_material_tags: { teaching_material_id: TeachingMaterial.where(user: current_user) })
                .distinct

      # リピート対象の問題を取得（既にソート済み）
      @repeat_materials = Homework.repeat_materials_for_group(@homework.account_group)
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to homeworks_path, alert: "指定された宿題は存在しないか、アクセス権限がありません"
  end

  # 問題を追加
  def add_material
    @homework = current_user.homeworks.find(params[:id])
    @material = TeachingMaterial.find(params[:material_id])
    
    unless @homework.teaching_materials.include?(@material)
      position = @homework.homework_materials.maximum(:position).to_i + 1
      @homework.homework_materials.create(teaching_material: @material, position: position)
    end

    redirect_to edit_homework_path(@homework), notice: "問題を追加しました"
  end

  def remove_material
    @homework = current_user.homeworks.find(params[:id])
    @material = TeachingMaterial.find(params[:material_id])
    
    @homework.homework_materials.find_by(teaching_material: @material)&.destroy

    # 残りの問題の位置を整列し直す
    @homework.homework_materials.order(:position).each.with_index do |material, index|
      material.update(position: index)
    end

    redirect_to edit_homework_path(@homework), notice: "問題を削除しました"
  end

  def create
    @homework = current_user.homeworks.build(homework_params)

    if @homework.save
      redirect_to edit_homework_path(@homework),
                  notice: "#{t('notices.created', model: Homework.model_name.human)}。問題を追加してください。"
    else
      @account_groups = AccountGroup.all
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
    params.require(:homework).permit(:title, :deadline, :account_group_id)
  end
end