class DicTitlesController < ApplicationController
  load_and_authorize_resource :dic_title

  def index
    @dic_titles_grid = initialize_grid(@dic_titles,
         :order => 'dic_titles.category',
         :order_direction => 'asc')
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @dic_title = DicTitle.new(dic_title_params)
    @dic_title.save
    respond_with(@dic_title)
  end

  def update
    @dic_title.update(dic_title_params)
    respond_with(@dic_title)
  end

  def destroy
    @dic_title.destroy
    respond_with(@dic_title)
  end

  private
    def set_dic_title
      @dic_title = DicTitle.find(params[:id])
    end

    def dic_title_params
      params[:dic_title]
    end
end
