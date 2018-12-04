class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
	  t.string   :module_name
      t.string   :operation
      t.boolean :is_show, default: true

      t.timestamps
    end
  end
end
