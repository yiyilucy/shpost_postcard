class FrontUsers::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    front_user = FrontUser.find_by(wechat_id: 'test')
    front_user ||= FrontUser.create(wechat_id: 'test', head_url: 'nil')
    # sign_in front_user
    # binding.pry
    redirect_to '/users/'
    # super
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end