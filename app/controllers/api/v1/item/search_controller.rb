class Api::V1::Item::SearchController < ApplicationController
  def show
    if name_and_price? || price_below_zero?
      render_invalid_params
    elsif item = Item.top_search(item_params)
      render json: ItemSerializer.new(Item.top_search(item_params))
    else
      render_not_found
    end
  end


  private

  def item_params
    params.permit(:name, :description, :unit_price, :merchant_id, :min_price, :max_price)
  end

  def render_invalid_params
    render json: { errors: "Invalid search parameters" }, status: :bad_request
  end

  def render_not_found
    render json: { data: {} }, status: :not_found
  end

  def name_and_price?
    item_params[:name] && item_params[:min_price] || item_params[:name] && item_params[:max_price]
  end

  def price_below_zero?
    if item_params[:min_price] || item_params[:max_price]
      item_params[:min_price].to_f < 0 || item_params[:max_price].to_f < 0
    end
  end
end
