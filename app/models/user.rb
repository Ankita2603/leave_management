class User < ApplicationRecord
  enum role: { employee: 0, manager: 1, hr: 2, admin: 3 }
  devise :database_authenticatable, :registerable, :recoverable, :validatable

  belongs_to :manager, class_name: "User", optional: true

  has_many :employees, class_name: "User", foreign_key: "manager_id"
  has_many :leave_applications, dependent: :destroy
  has_many :approved_leaves, class_name: "LeaveApplication", foreign_key: "approver_id"

  validates :role, presence: true
  validates :password, format: {
        with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/,
        message: "must include at least one uppercase letter, one lowercase letter, one digit, and one special character"
      }, on: :create

  def can_approve_leaves_for?(user)
    return true if admin? || hr?
    return true if manager? && user.manager_id == self.id
    false
  end

  def can_approve_leaves?
    admin? || hr? || manager?
  end
end
