class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create!(item_params)), status: :created
  end

  def update
    if params[:merchant_id] == nil || Merchant.exists?(params[:merchant_id])
      render json: ItemSerializer.new(Item.update(params[:id], item_params))
    else
      render json: { errors: "Merchant does not exist" }, status: :not_found
    end
  end

  def destroy
    Item.destroy(params[:id])
  end

  private

  def item_params
    params.permit(:name, :description, :unit_price, :merchant_id)
  end
end
