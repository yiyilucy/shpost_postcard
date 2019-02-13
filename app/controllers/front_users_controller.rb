class FrontUsersController < ApplicationController
  load_and_authorize_resource
  user_logs_filter only: :update, operation: :operation, symbol: :name

  def index
     @front_users_grid = initialize_grid(@front_users,
         :order => 'front_users.id',
         :order_direction => 'asc',
         :name => 'front_users',
         :enable_export_to_csv => true,
         :csv_file_name => 'front_users')
     
     export_grid_if_requested
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @front_user.save
        format.html { redirect_to @front_user, notice: I18n.t('controller.create_success_notice', model: '前台用户') }
        format.json { render action: 'show', status: :created, location: @front_user }
      else
        format.html { render action: 'new' }
        format.json { render json: @front_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @operation = "update"
    respond_to do |format|
      if @front_user.update(front_user_params)
        format.html { redirect_to @front_user, notice: I18n.t('controller.update_success_notice', model: '前台用户')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @front_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @front_user.destroy
    respond_to do |format|
      format.html { redirect_to front_users_url }
      format.json { head :no_content }
    end
  end

  def collection_index
    redirect_to collection_index_collections_path(@front_user)
  end

  private
    def set_front_user
      @front_user = FrontUser.find(params[:id])
    end

    def front_user_params
      params.require(:front_user).permit(:name, :nickname, :phone, :email)
    end
end
