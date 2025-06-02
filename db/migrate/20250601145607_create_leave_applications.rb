class CreateLeaveApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :leave_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.text :reason
      t.integer :status
      t.text :rejection_reason
      t.boolean :edited

      t.timestamps
    end
  end
end
