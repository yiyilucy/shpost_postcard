class CreateCatalogs < ActiveRecord::Migration
  def change
    create_table :catalogs do |t|

      t.string :catalog_no,    :null => false
      t.string :catalog_name,    :null => false
      t.string :catalog_type,    :null => false
      t.boolean :is_show,:default => true
    end
  end
end
