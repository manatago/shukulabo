class DashboardController < ApplicationController
  def index
    @teaching_materials = current_user.teaching_materials.order(created_at: :desc).limit(5)
    @tags = Tag.joins(:teaching_materials)
              .where(teaching_materials: { user_id: current_user.id })
              .distinct
              .limit(10)
  end
end