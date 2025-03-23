class TagsController < ApplicationController
  before_action :set_tag, only: [:edit, :update, :destroy]
  before_action :require_admin!

  def index
    @tags = Tag.all.order(:name)
  end

  def new
    @tag = Tag.new
  end

  def edit
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      redirect_to tags_path, notice: t('notices.created', model: Tag.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to tags_path, notice: t('notices.updated', model: Tag.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @tag.teaching_materials.any?
      redirect_to tags_path, alert: '教材で使用されているタグは削除できません'
    else
      @tag.destroy
      redirect_to tags_path, notice: t('notices.deleted', model: Tag.model_name.human)
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end