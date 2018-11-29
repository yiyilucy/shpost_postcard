class UserPermissionsController < ApplicationController
  before_action :set_user_permission, only: [:show, :edit, :update, :destroy]

  def index
    @user_permissions = UserPermission.all
    respond_with(@user_permissions)
  end

  def show
    respond_with(@user_permission)
  end

  def new
    @user_permission = UserPermission.new
    respond_with(@user_permission)
  end

  def edit
  end

  def create
    @user_permission = UserPermission.new(user_permission_params)
    @user_permission.save
    respond_with(@user_permission)
  end

  def update
    @user_permission.update(user_permission_params)
    respond_with(@user_permission)
  end

  def destroy
    @user_permission.destroy
    respond_with(@user_permission)
  end

  private
    def set_user_permission
      @user_permission = UserPermission.find(params[:id])
    end

    def user_permission_params
      params[:user_permission]
    end
end
