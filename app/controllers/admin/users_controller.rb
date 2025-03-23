class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:edit, :update, :toggle_admin]
  before_action :protect_last_admin, only: [:toggle_admin]

  def index
    @users = User.includes(:account_group).order(created_at: :desc)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: t('notices.updated', model: User.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_admin
    @user.update(is_admin: !@user.is_admin)
    redirect_to admin_users_path, notice: "#{@user.name}の管理者権限を#{@user.admin? ? '付与' : '削除'}しました"
  end

  def impersonate
    user = User.find(params[:id])
    session[:admin_id] = current_user.id
    session[:user_id] = user.id
    redirect_to root_path, notice: "#{user.name}として操作を開始しました"
  end

  def stop_impersonating
    return unless session[:admin_id]
    session[:user_id] = session[:admin_id]
    session.delete(:admin_id)
    redirect_to admin_users_path, notice: "管理者アカウントに戻りました"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :account_group_id)
  end

  def protect_last_admin
    if @user.admin? && User.where(is_admin: true).count == 1
      redirect_to admin_users_path, alert: '最後の管理者は管理者権限を削除できません'
      return
    end
  end
end