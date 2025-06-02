class AddColumnToLeaveApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :leave_applications, :approver_id, :integer
  end
end
