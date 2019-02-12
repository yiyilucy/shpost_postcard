class CreateDicTitles < ActiveRecord::Migration
  def change
    create_table :dic_titles do |t|
      t.string :name, :null => false
      t.string :category, :null => false
      t.string :db_field, :null => false

      t.timestamps
    end
  end
end
