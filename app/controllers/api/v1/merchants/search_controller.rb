class Api::V1::Merchants::SearchController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.search(merchant_params))
  end

  private

  def merchant_params
    params.permit(:name)
  end
end
