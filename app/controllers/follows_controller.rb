class FollowsController < ApplicationController
  load_and_authorize_resource 

  def index
  	# @commodity_id = nil
   #  @front_user_id = nil
   #  if !params[:commodity_id].blank?
   #    @commodity_id = params[:commodity_id].to_i
   #    @follows = Commodity.where(commodity_id: @commodity_id )
   #  end
   #  @follows_grid = initialize_grid(@follows) 
    render layout: false
    # redirect_to  product_follow_follows_path
  end

  def product_follow
    render layout: false
  end

  def create
  	@commodity = Commodity.find(params[:commodity_id])
    if !current_front_user.has_follow? @commodity
  		@follow = Follow.create(front_user: current_front_user, commodity: @commodity)
  	end
  	respond_to do |format|
  		format.html { redirect_to  "/sortings/product_sorting?commodity_id=#{@commodity.id}" }
  	end
    # @follow = Follow.new(follow_params)
    # @follow.save
    # respond_with(@follow)
    # respond_to do |format|
    #    if @follow.save
    #       format.html { redirect_to "/follows/product_follow", notice: I18n.t('controller.create_success_notice', model: '字典内容') }
    #       format.json { head :no_content }
    #     else
    #       format.html { redirect_to "/sortings/product_sorting" }
    #       format.json { render json: @follow.errors, status: :unprocessable_entity }
    #     end
    # end
  end

  def update
    # @follow.update(follow_params)
    # respond_with(@follow)
    
  end

  def show
  end

  def new
  end

  def destroy
    # @follow.destroy
    # respond_with(@follow)
    @commodity = Commodity.find(params[:commodity_id])
    follow = Follow.find_by(commodity_id: params[:commodity_id])
    # binding.pry
  	follow.destroy
  	respond_to do |format|
      format.html {redirect_to  "/sortings/product_sorting?commodity_id=#{@commodity.id}" }
  		# format.html { redirect_to "/sortings/product_sorting.#{@commodity.id}" }
  	end
  end
end
