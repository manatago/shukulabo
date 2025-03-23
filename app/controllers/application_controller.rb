class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  helper_method :current_user, :user_signed_in?, :require_admin!, :true_user, :impersonating?

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to root_path, alert: 'ログインが必要です'
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_admin!
    unless true_user&.admin?
      redirect_to root_path, alert: '管理者権限が必要です'
    end
  end

  def true_user
    @true_user ||= User.find_by(id: session[:admin_id]) || current_user
  end

  def impersonating?
    session[:admin_id].present?
  end
end
