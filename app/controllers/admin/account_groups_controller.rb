class Admin::AccountGroupsController < Admin::BaseController
  before_action :set_account_group, only: [:edit, :update, :destroy]

  def index
    @account_groups = AccountGroup.all.includes(:users)
  end

  def new
    @account_group = AccountGroup.new
  end

  def edit
  end

  def create
    @account_group = AccountGroup.new(account_group_params)

    if @account_group.save
      redirect_to admin_account_groups_path, notice: t('notices.created', model: AccountGroup.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @account_group.update(account_group_params)
      redirect_to admin_account_groups_path, notice: t('notices.updated', model: AccountGroup.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @account_group.users.any?
      redirect_to admin_account_groups_path, alert: '生徒が所属しているグループは削除できません'
    else
      @account_group.destroy
      redirect_to admin_account_groups_path, notice: t('notices.deleted', model: AccountGroup.model_name.human)
    end
  end

  private

  def set_account_group
    @account_group = AccountGroup.find(params[:id])
  end

  def account_group_params
    params.require(:account_group).permit(:name)
  end
end