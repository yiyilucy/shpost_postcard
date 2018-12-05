class CreateStamps < ActiveRecord::Migration
  def change
    create_table :stamps do |t|
      t.string :serial_no
      t.string :format
      t.string :theme
      t.string :version
      t.string :designer
      t.string :ori_author
      t.string :engrave_author
      t.datetime :issue_at
      t.string :issue_unit
      t.string :print_unit
      t.string :gum
      t.string :circulation
      t.string :set_amount
      t.string :page_amount
      t.string :perforation
      t.string :specification
      t.string :editor
      
      t.timestamps
    end
  end
end
