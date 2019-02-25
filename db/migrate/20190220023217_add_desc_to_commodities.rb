class AddDescToCommodities < ActiveRecord::Migration
  def change
  	add_column :commodities, :desc, :string
  end
end
