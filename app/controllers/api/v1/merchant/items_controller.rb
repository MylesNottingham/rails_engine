class Api::V1::Merchant::ItemsController < ApplicationController
  def index
    if params[:merchant_id].is_a?(Integer) || Merchant.exists?(params[:merchant_id])
      render json: ItemSerializer.new(Merchant.find(params[:merchant_id]).items)
    else
      render json: { errors: "Merchant not found" }, status: :not_found
    end
  end
end
