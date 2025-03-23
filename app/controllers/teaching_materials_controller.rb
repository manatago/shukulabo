class TeachingMaterialsController < ApplicationController
  before_action :set_teaching_material, only: [:show, :edit, :update, :destroy]

  def index
    @teaching_materials = current_user.teaching_materials
                                    .includes(:tags)
                                    .order(created_at: :desc)
  end

  def show
  end

  def new
    @teaching_material = current_user.teaching_materials.build
  end

  def edit
  end

  def create
    @teaching_material = current_user.teaching_materials.build(teaching_material_params)

    if @teaching_material.save
      redirect_to @teaching_material, notice: t('notices.created', model: TeachingMaterial.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @teaching_material.update(teaching_material_params)
      redirect_to @teaching_material, notice: t('notices.updated', model: TeachingMaterial.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @teaching_material.destroy
    redirect_to teaching_materials_url, notice: t('notices.deleted', model: TeachingMaterial.model_name.human)
  end

  def search
    if params[:tag]
      @teaching_materials = current_user.teaching_materials
                                      .joins(:tags)
                                      .where(tags: { name: params[:tag] })
                                      .distinct
    else
      @teaching_materials = current_user.teaching_materials
    end
    render :index
  end

  private

  def set_teaching_material
    @teaching_material = current_user.teaching_materials.find(params[:id])
  end

  def teaching_material_params
    params.require(:teaching_material).permit(
      :title,
      :question_text,
      :answer_text,
      :correct_answer,
      :question_image,
      :answer_image,
      tag_ids: []
    )
  end
end