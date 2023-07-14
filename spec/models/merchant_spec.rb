require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items) }
  end

  describe "class methods" do
    it "#self.search" do
      merchant_1 = create(:merchant, name: "Turing")
      merchant_2 = create(:merchant, name: "Ring World")
      merchant_3 = create(:merchant, name: "Earring World")

      expect(Merchant.search({name: "ring"})).to eq([merchant_1, merchant_2, merchant_3])

      expect(Merchant.search({name: "ear"})).to eq([merchant_3])
      expect(Merchant.search({name: "ear"})).to_not eq([merchant_1, merchant_2])

      expect(Merchant.search({name: "zzz"})).to eq([])
      expect(Merchant.search({name: "zzz"})).to_not eq([merchant_1, merchant_2, merchant_3])
    end
  end
end
