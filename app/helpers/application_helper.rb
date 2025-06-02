module ApplicationHelper
  def current_user_admin_or_hr?
    current_user.admin? || current_user.hr?
  end
end
