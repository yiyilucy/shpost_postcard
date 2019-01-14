class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :commodity_id, :null => false
      t.datetime :price_date, :null => false
      t.float :price, :null => false
      t.boolean :is_show, default: true

      t.timestamps
    end
  end
end
