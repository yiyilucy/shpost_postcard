class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
	  t.string   :module
      t.string   :operation

      t.timestamps
    end
  end
end
