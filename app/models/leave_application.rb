class LeaveApplication < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: "User", optional: true

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validate :max_five_days
  validate :no_weekend_days
  validate :safe_input
  validate :dates_cannot_be_in_past
  validate :no_overlapping_leave
  validates :rejection_reason, presence: true, if: -> { rejected? }

  def number_of_leave_days
    (start_date..end_date).to_a.reject { |d| d.saturday? || d.sunday? }.count
  end

  private

  def dates_cannot_be_in_past
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "cannot be in the past")
    end

    if end_date.present? && end_date < Date.today
      errors.add(:end_date, "cannot be in the past")
    end
  end

  def no_overlapping_leave
    return unless start_date && end_date

    overlapping_leave = LeaveApplication
      .where(user_id: user_id)
      .where.not(status: 'rejected')
      .where.not(id: id) 
      .where("start_date <= ? AND end_date >= ?", end_date, start_date)
      .exists?

    if overlapping_leave
      errors.add(:base, "You already have leave applied for overlapping dates.")
    end
  end

  def max_five_days
    if start_date && end_date && number_of_leave_days > 5
      errors.add(:base, "You cannot apply for more than 5 days (excluding weekends).")
    end
  end

  def no_weekend_days
    if (start_date..end_date).all? { |d| d.saturday? || d.sunday? }
      errors.add(:base, "Leave cannot be only on weekends.")
    end
  end

  def safe_input
    if reason =~ /<[^>]+>|<script.*?>.*?<\/script>/im
      errors.add(:reason, "Invalid characters detected")
    end
  end
end
