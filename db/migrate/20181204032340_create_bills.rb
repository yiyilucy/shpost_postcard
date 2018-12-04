class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.string :version
      t.datetime :issue_at
      t.string :engrave_year
      t.string :face_value
      t.string :pack_spec
      t.string :head
      t.string :tail
      t.string :prefix
      t.string :serial_no
      t.string :watermark
      t.string :print_process
      t.integer :commodity_id

      t.timestamps
    end
  end
end
