require "rails_helper"

RSpec.describe Item, type: :model do
  describe "relationships" do
    it { should belong_to(:merchant) }
  end

  describe "class methods" do
    it "#self.top_search" do
      merchant = create(:merchant)
      item_1 = create(:item, merchant: merchant, unit_price: 100)
      item_2 = create(:item, merchant: merchant, unit_price: 200)
      item_3 = create(:item, merchant: merchant, unit_price: 300)
      item_4 = create(:item, merchant: merchant, unit_price: 400)
      item_5 = create(:item, merchant: merchant, unit_price: 500)

      expect(Item.top_search({min_price: 350})).to eq(item_4)
      expect(Item.top_search({min_price: 150})).to eq(item_2)
      expect(Item.top_search({max_price: 250})).to eq(item_2)
      expect(Item.top_search({max_price: 450})).to eq(item_4)

      expect(Item.top_search({min_price: 250, max_price: 350})).to eq(item_3)
    end
  end
end
