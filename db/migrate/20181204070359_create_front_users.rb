class CreateFrontUsers < ActiveRecord::Migration
  def change
    create_table :front_users do |t|
      t.string :name
      t.string :nickname
      t.integer :phone
      t.string :status, :null => false, default: "unauthen" 
      t.string :authen_code
      t.string :wechat_id, :null => false
      t.string :email
      t.string :head_url, :null => false

      t.timestamps
    end
  end
end
