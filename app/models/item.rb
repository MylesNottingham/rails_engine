class Item < ApplicationRecord
  belongs_to :merchant

  def self.top_search(params)
    if params[:name]
      where("name ILIKE ?", "%#{params[:name]}%").first
    elsif params[:min_price] && params[:max_price]
      where("unit_price >= ? AND unit_price <= ?", params[:min_price].to_f, params[:max_price].to_f).order(:unit_price).first
    elsif params[:min_price]
      where("unit_price >= ?", params[:min_price].to_f).order(:unit_price).first
    elsif params[:max_price]
      where("unit_price <= ?", params[:max_price].to_f).order(:unit_price).last
    end
  end
end
