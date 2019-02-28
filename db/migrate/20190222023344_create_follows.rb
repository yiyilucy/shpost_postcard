class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :commodity_id, null: false
      t.integer :front_user_id, null: false

      t.timestamps
    end
  end
end
