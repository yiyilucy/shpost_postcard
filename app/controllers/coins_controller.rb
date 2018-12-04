class CoinsController < ApplicationController
  before_action :set_coin, only: [:show, :edit, :update, :destroy]

  def index
    @coins = Coin.all
    respond_with(@coins)
  end

  def show
    respond_with(@coin)
  end

  def new
    @coin = Coin.new
    respond_with(@coin)
  end

  def edit
  end

  def create
    @coin = Coin.new(coin_params)
    @coin.save
    respond_with(@coin)
  end

  def update
    @coin.update(coin_params)
    respond_with(@coin)
  end

  def destroy
    @coin.destroy
    respond_with(@coin)
  end

  private
    def set_coin
      @coin = Coin.find(params[:id])
    end

    def coin_params
      params[:coin]
    end
end
