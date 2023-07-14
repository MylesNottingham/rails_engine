require "rails_helper"

describe "Items API" do
  let(:merchant) { create(:merchant) }

  describe "GET /api/v1/items" do
    context "happy path" do
      it "can get a list of items" do
        create_list(:item, 3, merchant: merchant)

        get "/api/v1/items"

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
  end

  describe "GET /api/v1/items/:id" do
    context "happy path" do
      it "can get one item by its id" do
        id = create(:item, merchant: merchant).id

        get "/api/v1/items/#{id}"

        item = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(response).to have_http_status(:success)

        expect(item).to have_key(:id)
        expect(item[:id].to_i).to eq(id)

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

    context "sad path" do
      it "returns status: :not_found if the item does not exist" do
        expect(Item.exists?(1)).to eq(false)

        get "/api/v1/items/1"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "edge case" do
      it "returns status: :not_found if the item id is not an integer" do
        get "/api/v1/items/one"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/items" do
    context "happy path" do
      it "can create a new item" do
        item_params = ({
                        name: "Fancy Item",
                        description: "It's a fancy item",
                        unit_price: 1.5,
                        merchant_id: merchant.id
                      })
        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/items", headers: headers, params: JSON.generate(item_params)

        created_item = Item.last

        expect(response).to have_http_status(:created)
        expect(created_item.name).to eq(item_params[:name])
        expect(created_item.description).to eq(item_params[:description])
        expect(created_item.unit_price).to eq(item_params[:unit_price])
        expect(created_item.merchant_id).to eq(item_params[:merchant_id])
      end
    end

    context "sad path" do
      it "returns status: :unprocessable_entity if merchant is missing" do
        item_params = ({
                        name: "Fancy Item",
                        description: "It's a fancy item",
                        unit_price: 1.5
                      })
        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/items", headers: headers, params: JSON.generate(item_params)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /api/v1/items/:id" do
    context "happy path" do
      it "can update an existing item" do
        id = create(:item, merchant: merchant).id
        previous_name = Item.last.name
        previous_description = Item.last.description
        previous_unit_price = Item.last.unit_price
        previous_merchant_id = Item.last.merchant_id

        new_name = "New Name"
        new_description = "New Description"
        new_unit_price = 2.5
        new_merchant_id = create(:merchant).id

        item_params = {
          name: new_name,
          description: new_description,
          unit_price: new_unit_price,
          merchant_id: new_merchant_id
        }
        headers = {"CONTENT_TYPE" => "application/json"}

        patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item_params)

        item = Item.find_by(id: id)

        expect(response).to have_http_status(:success)

        expect(item.name).to_not eq(previous_name)
        expect(item.name).to eq(new_name)

        expect(item.description).to_not eq(previous_description)
        expect(item.description).to eq(new_description)

        expect(item.unit_price).to_not eq(previous_unit_price)
        expect(item.unit_price).to eq(new_unit_price)

        expect(item.merchant_id).to_not eq(previous_merchant_id)
        expect(item.merchant_id).to eq(new_merchant_id)
      end

      it "works with partial data" do
        id = create(:item, merchant: merchant).id
        previous_name = Item.last.name
        new_name = "New Name"
        item_params = { name: new_name }
        headers = {"CONTENT_TYPE" => "application/json"}

        patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item_params)

        item = Item.find_by(id: id)

        expect(response).to have_http_status(:success)
        expect(item.name).to_not eq(previous_name)
        expect(item.name).to eq(new_name)
      end
    end

    context "sad path" do
      it "returns status: :not_found if the item does not exist" do
        expect(Item.exists?(1)).to eq(false)

        item_params = { name: "New Name" }
        headers = {"CONTENT_TYPE" => "application/json"}

        patch "/api/v1/items/1", headers: headers, params: JSON.generate(item_params)

        expect(response).to have_http_status(:not_found)
      end

      it "returns status: :not_found if merchant does not exist" do
        id = create(:item, merchant: merchant).id
        item_params = { merchant_id: 999999 }
        headers = {"CONTENT_TYPE" => "application/json"}

        patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item_params)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /api/v1/items/:id" do
    context "happy path" do
      it "can destroy an item" do
        item = create(:item, merchant: merchant)

        expect(Item.count).to eq(1)
        expect{Item.find(item.id)}.to_not raise_error

        delete "/api/v1/items/#{item.id}"

        expect(response).to have_http_status(:success)

        expect(Item.count).to eq(0)
        expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "sad path" do
      it "returns status: :not_found if the item does not exist" do
        expect(Item.exists?(1)).to eq(false)

        delete "/api/v1/items/1"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/v1/items/:id/merchant" do
    context "happy path" do
      it "can get the merchant associated with an item" do
        item = create(:item, merchant: merchant)

        get "/api/v1/items/#{item.id}/merchant"

        expect(response).to have_http_status(:success)

        merchant = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(merchant).to have_key(:id)
        expect(merchant[:id].to_i).to eq(item.merchant.id)

        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to be_a(Hash)

        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end

    context "sad path" do
      it "returns status: :not_found if the item does not exist" do
        expect(Item.exists?(1)).to eq(false)

        get "/api/v1/items/1/merchant"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/v1/items/find" do
    context "happy path" do
      it "can find an item by name fragment" do
        item = create(:item, name: "Fancy Item", merchant: merchant)

        get "/api/v1/items/find?name=ancy"

        expect(response).to have_http_status(:success)

        found_item = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(found_item).to have_key(:id)
        expect(found_item[:id].to_i).to eq(item.id)

        expect(found_item).to have_key(:attributes)
        expect(found_item[:attributes]).to be_a(Hash)

        expect(found_item[:attributes]).to have_key(:name)
        expect(found_item[:attributes][:name]).to be_a(String)
      end

      it "can find and select the first item alphabetically by min price" do
        item_a = create(:item, name: "A", merchant: merchant, unit_price: 1.5)
        item_b = create(:item, name: "B", merchant: merchant, unit_price: 2.5)
        item_c = create(:item, name: "C", merchant: merchant, unit_price: 3.5)

        get "/api/v1/items/find?min_price=2"

        expect(response).to have_http_status(:success)

        found_item = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(found_item).to have_key(:id)
        expect(found_item[:id].to_i).to eq(item_b.id)

        expect(found_item).to have_key(:attributes)
        expect(found_item[:attributes]).to be_a(Hash)

        expect(found_item[:attributes]).to have_key(:name)
        expect(found_item[:attributes][:name]).to be_a(String)
      end

      it "can find an item by max price" do
        item_a = create(:item, name: "A", merchant: merchant, unit_price: 1.5)
        item_b = create(:item, name: "B", merchant: merchant, unit_price: 2.5)
        item_c = create(:item, name: "C", merchant: merchant, unit_price: 3.5)

        get "/api/v1/items/find?max_price=2"

        expect(response).to have_http_status(:success)

        found_item = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(found_item).to have_key(:id)
        expect(found_item[:id].to_i).to eq(item_a.id)

        expect(found_item).to have_key(:attributes)
        expect(found_item[:attributes]).to be_a(Hash)

        expect(found_item[:attributes]).to have_key(:name)
        expect(found_item[:attributes][:name]).to be_a(String)
      end
    end

    context "sad path" do
      it "returns error if min price is below zero" do
        item = create(:item, unit_price: 1.5, merchant: merchant)

        get "/api/v1/items/find?min_price=-1"

        expect(response).to have_http_status(:bad_request)

        error = JSON.parse(response.body, symbolize_names: true)[:errors]

        expect(error).to eq("Invalid search parameters")
      end

      it "returns error if max price is below zero" do
        item = create(:item, unit_price: 1.5, merchant: merchant)

        get "/api/v1/items/find?max_price=-1"

        expect(response).to have_http_status(:bad_request)

        error = JSON.parse(response.body, symbolize_names: true)[:errors]

        expect(error).to eq("Invalid search parameters")
      end

      it "returns error if item does not exist" do
        expect(Item.exists?(1)).to eq(false)

        get "/api/v1/items/find?name=ancy"

        expect(response).to have_http_status(:not_found)

        error = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(error).to eq({})
      end
    end
  end
end
