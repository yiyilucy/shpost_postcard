class StampsController < ApplicationController
  before_action :set_stamp, only: [:show, :edit, :update, :destroy]

  def index
    @stamps = Stamp.all
    respond_with(@stamps)
  end

  def show
    respond_with(@stamp)
  end

  def new
    @stamp = Stamp.new
    respond_with(@stamp)
  end

  def edit
  end

  def create
    @stamp = Stamp.new(stamp_params)
    @stamp.save
    respond_with(@stamp)
  end

  def update
    @stamp.update(stamp_params)
    respond_with(@stamp)
  end

  def destroy
    @stamp.destroy
    respond_with(@stamp)
  end

  private
    def set_stamp
      @stamp = Stamp.find(params[:id])
    end

    def stamp_params
      params[:stamp]
    end
end
