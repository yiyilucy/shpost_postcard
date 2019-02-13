class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.integer :commodity_id, null: false
      t.integer :front_user_id, null: false
      t.integer :amount, null: false
      t.decimal :cost, :precision => 10, :scale => 2, null: false
      t.string :desc

      t.timestamps
    end
  end
end
