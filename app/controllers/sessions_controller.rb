class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :failure]

  def create
    auth = request.env['omniauth.auth']
    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    if user.new_record?
      user.email = auth.info.email
      user.name = auth.info.name
      user.is_admin = User.count.zero? # 最初のユーザーを管理者に
      user.save!
    end

    session[:user_id] = user.id
    redirect_to session.delete(:return_to) || dashboard_path, notice: 'ログインしました'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_path, alert: '認証に失敗しました'
  end
end