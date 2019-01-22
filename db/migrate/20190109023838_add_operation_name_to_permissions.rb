class AddOperationNameToPermissions < ActiveRecord::Migration
  def change
  	add_column :permissions, :operation_name, :string
  end
end
