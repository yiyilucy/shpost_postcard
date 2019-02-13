class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :title
      t.string :link
      t.boolean :is_show, default: true
      t.integer :order, default: 1
      t.string :pic_name, null: false

      t.timestamps
    end
  end
end
