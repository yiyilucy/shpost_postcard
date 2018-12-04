class CreateCommodities < ActiveRecord::Migration
  def change
    create_table :commodities do |t|
      t.string :no, :null => false, :unique => true
      t.string :name, :null => false
      t.string :short_name
      t.string :common_name
      t.integer :catalog_id, :null => false
      t.string :category, :null => false
      t.boolean :is_show, default: true
      t.string :pic_name

      t.timestamps
    end
  end
end
