class PermissionsController < ApplicationController
  load_and_authorize_resource :permission
  user_logs_filter only: :do_permission, symbol: :username, object: :permission, operation: :operation

  def index
    @permissions = Permission.where(is_show: true).group(:module_name).order(:created_at).count
    @user = params[:user]
  end

  def show
  end

  def new
    @permissions = Permission.where(is_show: true).group(:module_name).order(:created_at).count
    @user = params[:user]
  end

  def edit
  end

  def create
    @permission = Permission.new(permission_params)
    @permission.save
    respond_with(@permission)
  end

  def update
    @permission.update(permission_params)
    respond_with(@permission)
  end

  def destroy
    @permission.destroy
    respond_with(@permission)
  end

  def do_permission
    @operation = "do_permission"
    @username = nil
    user_id = nil
    if !params[:checkbox].blank? and !params[:user_id].blank?
      user_id = params[:user_id].to_i
      @username = User.find(user_id).username
      
      ActiveRecord::Base.transaction do
        begin
          params[:checkbox].each do |x|
            if !x[0].blank? and !x[0].split("_").blank? and !x[0].split("_")[1].blank?
              permission_id = x[0].split("_")[1].to_i            
              ori_permission = UserPermission.find_by(user_id: user_id, permission_id: permission_id)
                  
              if x[1].eql?"1"          
                if ori_permission.blank?
                  UserPermission.create(user_id: user_id, permission_id: permission_id)
                end
              elsif x[1].eql?"0"
                if !ori_permission.blank?
                  ori_permission.delete
                end
              end
            end
          end
          flash[:notice] = "赋权成功!"
        rescue Exception => e
          flash[:alert] = e.message
          raise ActiveRecord::Rollback
        end
      end  
    end
    redirect_to "/permissions/new?user=#{user_id}"
  end

  private
    def set_permission
      @permission = Permission.find(params[:id])
    end

    def permission_params
      params[:permission]
    end
end
