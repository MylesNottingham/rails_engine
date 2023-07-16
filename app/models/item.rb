class Item < ApplicationRecord
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :merchants, through: :invoices
  has_many :customers, through: :invoices
  belongs_to :merchant

  def self.top_search(params)
    if params[:name]
      where("name ILIKE ?", "%#{params[:name]}%").first
    elsif params[:min_price] && params[:max_price]
      where("unit_price >= ? AND unit_price <= ?", params[:min_price].to_f, params[:max_price].to_f).order(:name).first
    elsif params[:min_price]
      where("unit_price >= ?", params[:min_price].to_f).order(:name).first
    elsif params[:max_price]
      where("unit_price <= ?", params[:max_price].to_f).order(:name).first
    end
  end
end
