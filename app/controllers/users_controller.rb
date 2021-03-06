class UsersController < ApplicationController
  load_and_authorize_resource :user

  user_logs_filter only: [:create, :update, :destroy, :reset_pwd], symbol: :username, object: :user, operation: :operation

  # GET /users
  # GET /users.json
  def index
    #@users = User.all
    @users_grid = initialize_grid(@users)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @new = true
    #@user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    # @operation = I18n.t("operation_name.#{"create"}")
    @operation = "create"

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: I18n.t('controller.create_success_notice', model: '用户') }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @operation = "update"
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: I18n.t('controller.update_success_notice', model: '用户') }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @operation = "destroy"
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def to_reset_pwd
  end

  def reset_pwd
    @operation = "reset_pwd"
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, notice: "密码重置成功" }
        format.json { head :no_content }
      else
        format.html { render action: 'reset_pwd' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

 
  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_user
    #   @user = User.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user].permit(:username, :name, :password, :email)
    end
end
