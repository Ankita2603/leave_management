class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :name, :string
    add_index :users, :role
    add_index :users, :name
  end
end
