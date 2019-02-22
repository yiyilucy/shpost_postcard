class AddColumnsToFrontUsers < ActiveRecord::Migration
  def change
  	add_column :front_users, :country, :string
  	add_column :front_users, :province, :string
  	add_column :front_users, :city, :string

  	rename_column :front_users, :name, :sex
  	rename_column :front_users, :wechat_id, :open_id
  	rename_column :front_users, :head_url, :headimgurl
  end
end
