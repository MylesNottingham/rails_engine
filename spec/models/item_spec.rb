require "rails_helper"

RSpec.describe Item, type: :model do
  describe "relationships" do
    it { should belong_to(:merchant) }
  end

  describe "class methods" do
    it "#self.top_search" do
      merchant = create(:merchant)
      item_a = create(:item, name: "A", merchant: merchant, unit_price: 100)
      item_b = create(:item, name: "B", merchant: merchant, unit_price: 200)
      item_c = create(:item, name: "C", merchant: merchant, unit_price: 300)
      item_d = create(:item, name: "D", merchant: merchant, unit_price: 400)
      item_e = create(:item, name: "E", merchant: merchant, unit_price: 500)

      expect(Item.top_search({min_price: 350})).to eq(item_d)
      expect(Item.top_search({min_price: 150})).to eq(item_b)
      expect(Item.top_search({max_price: 250})).to eq(item_a)
      expect(Item.top_search({max_price: 450})).to eq(item_a)

      expect(Item.top_search({min_price: 250, max_price: 350})).to eq(item_c)
    end
  end
end
