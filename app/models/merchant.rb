class Merchant < ApplicationRecord
  has_many :items

  def self.search(params)
    where("name ILIKE ?", "%#{params[:name]}%")
  end
end
