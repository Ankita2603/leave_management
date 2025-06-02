class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_or_hr!
  before_action :set_user, only: [:edit, :update]

  def index
    @users = User.where(role: "employee")
  end

  def edit
    @user = User.find(params[:id])
    @managers = User.where(role: "manager")
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: "Employee updated successfully"
    else
      render :edit
    end
  end

  private

  def authorize_admin_or_hr!
    unless current_user.admin? || current_user.hr?
      redirect_to root_path, alert: "Access denied."
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :manager_id)
  end
end
