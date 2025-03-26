class Admin::LoginHistoriesController < Admin::BaseController
  def index
    @login_histories = LoginHistory.includes(:user).page(params[:page]).per(50)
  end
end