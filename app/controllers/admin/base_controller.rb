class Admin::BaseController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    unless user_signed_in?
      redirect_to root_path, alert: "ログインが必要です"
      return
    end

    unless current_user.admin?
      redirect_to root_path, alert: "管理者権限が必要です"
    end
  end
end