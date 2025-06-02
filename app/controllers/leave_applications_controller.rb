require "csv"

class LeaveApplicationsController < ApplicationController
  before_action :set_leave, only: [:edit, :update, :approve, :reject]

  def index
    @leaves = current_user.leave_applications
  end

	def new
		@leave = LeaveApplication.new
	end

  def create
    @leave = current_user.leave_applications.new(leave_params)
    @leave.status = :pending
    if @leave.save
      redirect_to leave_applications_path, notice: "Leave applied."
    else
      render :new
    end
  end

  def edit
    redirect_to leave_applications_path unless @leave_application.status == 'pending'
  end

  def update
    if @leave_application.update(leave_params)
      broadcast_leave_change(@leave_application, edited: true)
      redirect_to leave_applications_path, notice: "Leave updated successfully."
    else
      render :edit
    end
  end

  def employee_leaves
    fetch_leave
  end

  def approve
    @leave_application.update(status: "accepted", approver: current_user)
    broadcast_leave_change(@leave_application)
    redirect_to leave_applications_path, notice: "Leave accepted."
  end

  def reject
    @leave_application = LeaveApplication.find(params[:id])
  end

  def update_rejection
    @leave_application = LeaveApplication.find(params[:id])
    if @leave_application.update(status: "rejected", approver: current_user, rejection_reason: params[:leave_application][:rejection_reason])
      redirect_to leave_applications_path, notice: "Leave rejected."
    else
      render :reject
    end
  end

  def export_csv
    if current_user.manager? || current_user.hr? || current_user.admin?
      csv_data = CSV.generate(headers: true) do |csv|
        csv << ["Employee", "Start Date", "End Date", "Status", "Reason"]
        fetch_leave.each do |leave|
          csv << [leave.user.name, leave.start_date.to_date, leave.end_date.to_date, leave.status, leave.reason]
        end
      end
      send_data csv_data, filename: "leaves-#{Date.today}.csv"
    else
      redirect_to leave_applications_path, alert: "Access denied."
    end
  end

  private

  def set_leave
    if current_user.manager?
      @leave_application = LeaveApplication.joins(:user)
                            .where(users: { manager_id: current_user.id })
                            .find(params[:id])
    elsif current_user.hr? || current_user.admin?
      @leave_application = LeaveApplication.find(params[:id])
    else
      @leave_application = current_user.leave_applications.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to leave_applications_path, alert: "Leave not found or you are not authorized."
  end

  def fetch_leave
    if current_user.admin?
      @leaves = LeaveApplication.includes(:user).all
    elsif current_user.hr?
      @leaves = LeaveApplication.joins(:user).where.not(users: { id: current_user.id }).includes(:user)
    elsif current_user.manager?
      @leaves = LeaveApplication.joins(:user).where(users: { manager_id: current_user.id }).includes(:user)
    else
      @leaves = current_user.leave_applications
    end
  end

  def leave_params
    params.require(:leave_application).permit(:start_date, :end_date, :reason)
  end

  def broadcast_leave_change(leave, edited: false)
    ActionCable.server.broadcast "leave_channel", {
      leave_id: leave.id,
      status: leave.status,
      edited: edited
    }
  end
end
