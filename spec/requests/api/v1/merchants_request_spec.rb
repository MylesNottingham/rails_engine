require "rails_helper"

describe "Merchants API" do
  describe "GET /api/v1/merchants" do
    context "happy path" do
      it "can get a list of merchants" do
        create_list(:merchant, 3)

        get "/api/v1/merchants"

        expect(response).to have_http_status(:success)

        merchants = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(merchants.count).to eq(3)

        merchants.each do |merchant|
          expect(merchant).to have_key(:id)
          expect(merchant[:id].to_i).to be_an(Integer)

          expect(merchant[:attributes]).to have_key(:name)
          expect(merchant[:attributes][:name]).to be_a(String)
        end
      end
    end
  end

  describe "GET /api/v1/merchants/:id" do
    context "happy path" do
      it "can get one merchant by its id" do
        id = create(:merchant).id

        get "/api/v1/merchants/#{id}"

        merchant = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(response).to have_http_status(:success)

        expect(merchant).to have_key(:id)
        expect(merchant[:id].to_i).to eq(id)

        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to be_a(Hash)

        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end

    context "sad path" do
      it "returns status: :not_found if merchant does not exist" do
        expect(Merchant.exists?(1)).to eq(false)

        get "/api/v1/merchants/1"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/v1/merchants/:id/items" do
    context "happy path" do
      it "can list items associated with a merchant" do
        merchant = create(:merchant)
        create_list(:item, 3, merchant: merchant)

        get "/api/v1/merchants/#{merchant.id}/items"

        expect(response).to have_http_status(:success)

        items = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(items.count).to eq(3)

        items.each do |item|
          expect(item).to have_key(:id)
          expect(item[:id].to_i).to be_an(Integer)

          expect(item).to have_key(:attributes)
          expect(item[:attributes]).to be_a(Hash)

          expect(item[:attributes]).to have_key(:name)
          expect(item[:attributes][:name]).to be_a(String)

          expect(item[:attributes]).to have_key(:description)
          expect(item[:attributes][:description]).to be_a(String)

          expect(item[:attributes]).to have_key(:unit_price)
          expect(item[:attributes][:unit_price]).to be_a(Float)

          expect(item[:attributes]).to have_key(:merchant_id)
          expect(item[:attributes][:merchant_id]).to eq(merchant.id)
        end
      end
    end

    context "sad path" do
      it "returns status: :not_found if the merchant does not exist" do
        expect(Merchant.exists?(1)).to eq(false)

        get "/api/v1/merchants/1/items"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/v1/merchants/find_all" do
    context "happy path" do
      it "can find all merchants matching name fragment" do
        create(:merchant, name: "Turing")
        create(:merchant, name: "Ring World")
        create(:merchant, name: "Earring World")

        get "/api/v1/merchants/find_all?name=ring"

        expect(response).to have_http_status(:success)

        merchants = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(merchants.count).to eq(3)

        merchants.each do |merchant|
          expect(merchant).to have_key(:id)
          expect(merchant[:id].to_i).to be_an(Integer)

          expect(merchant).to have_key(:attributes)
          expect(merchant[:attributes]).to be_a(Hash)

          expect(merchant[:attributes]).to have_key(:name)
          expect(merchant[:attributes][:name]).to be_a(String)
        end
      end
    end

    context "sad path" do
      it "returns an empty array if no merchants match" do
        create(:merchant, name: "Turing")
        create(:merchant, name: "Ring World")
        create(:merchant, name: "Earring World")

        get "/api/v1/merchants/find_all?name=zzz"

        expect(response).to have_http_status(:success)

        merchants = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(merchants).to eq([])
      end
    end
  end
end
