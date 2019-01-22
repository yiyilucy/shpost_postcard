class Users::SessionsController < Devise::SessionsController
  # user_logs_filter only: [:create, :destroy], symbol: :username, object: :user, operation: :operation
  def create
    # @operation = "sign_in"
  	puts "Users::SessionsController start"
    super do |resource|
      puts "test Users::SessionsController"
      @user_log = UserLog.create(user: current_user, operation: 'sign_in', object_class: 'User', object_primary_key: current_user.id)

    end
    puts "Users::SessionsController end"
  end

  def destroy
    # @operation = "sign_out"
  	@user_log = UserLog.create(user: current_user, operation: 'sign_out', object_class: 'User', object_primary_key: current_user.id)
  	super do |resource|
  		session[:current_storage] = nil
  	end
  end
end