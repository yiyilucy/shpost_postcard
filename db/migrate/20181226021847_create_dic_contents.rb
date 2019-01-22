class CreateDicContents < ActiveRecord::Migration
  def change
    create_table :dic_contents do |t|
      t.string :name, :null => false
      t.integer :dic_title_id, :null => false
      t.boolean :is_show, default: true
      t.integer :order, default: 0

      t.timestamps
    end
  end
end
