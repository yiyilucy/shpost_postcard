json.array!(@front_users) do |front_user|
  json.extract! front_user, :name, :nickname, :phone, :email, :status
  json.url front_user_url(front_user, format: :json)
end
