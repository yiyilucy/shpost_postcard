class CreateSequences < ActiveRecord::Migration
  def change
    create_table :sequences do |t|
      t.string :entity
      t.integer :count
      t.timestamps
    end
  end
end