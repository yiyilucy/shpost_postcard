class AddDetailToCommodities < ActiveRecord::Migration
  def change
    add_column :commodities, :detail_id, :integer
    add_column :commodities, :detail_type, :string

    add_index :commodities, [:detail_type, :detail_id]
  end
end
