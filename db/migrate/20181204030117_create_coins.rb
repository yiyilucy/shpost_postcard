class CreateCoins < ActiveRecord::Migration
  def change
    create_table :coins do |t|
      t.string :theme
      t.string :issue_unit
      t.string :circulation
      t.string :material
      t.string :weight
      t.string :year
      t.string :face_value
      t.string :pack_spec
      t.string :cast_unit
      t.string :diameter
      t.string :percentage
      t.string :quality
      t.string :shape
      t.string :head
      t.string :tail
      
      t.timestamps
    end
  end
end
