class DashboardController < ApplicationController
  def index
    return unless user_signed_in?  # 念のため追加

    @teaching_materials = current_user.teaching_materials.order(created_at: :desc).limit(5)
    @tags = Tag.joins(:teaching_materials)
              .where(teaching_materials: { user_id: current_user.id })
              .distinct
              .limit(10)
  end
end