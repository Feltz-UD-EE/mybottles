require "test_helper"

class BottlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    @vintage = Vintage.create!(vintage: "2024", wine: wine)
  end

  test "lists bottles with dynamic table UI" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, purchase_date: Date.new(2026, 6, 6), disposal_method: "Drink")

    get bottles_url

    assert_response :success
    assert_select "h1", "Bottles"
    assert_select "[data-controller='table']"
    assert_select "td", "A-001"
    assert_select "td", "Producer - Estate Red - 2024"
    assert_select "td", "2026-06-06"
    assert_select "a[href=?]", new_tasting_note_path(tasting_note: { tasteable_type: "Bottle", tasteable_id: bottle.id }), text: "Tasted This"
  end

  test "show title includes producer wine and vintage and tasting note launch" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")

    get bottle_url(bottle)

    assert_response :success
    assert_select "h1", "Producer - Estate Red - 2024"
    assert_select "a[href=?]", new_tasting_note_path(tasting_note: { tasteable_type: "Bottle", tasteable_id: bottle.id }), text: "Tasted This"
  end

  test "creates updates and deletes bottle" do
    assert_difference("Bottle.count", 1) do
      post bottles_url, params: { bottle: { personal_inventory: "A-002", vintage_id: @vintage.id, purchase_date: "2026-06-06", list_price: "25.00", disposal_method: "Drink" } }
    end

    bottle = Bottle.order(:created_at).last
    assert_redirected_to bottle_url(bottle)

    patch bottle_url(bottle), params: { bottle: { personal_inventory: "A-003", vintage_id: @vintage.id, discount_price: "20.00", disposal_method: "Gift", disposal_date: "2026-06-07" } }
    assert_redirected_to bottle_url(bottle)
    assert_equal "A-003", bottle.reload.personal_inventory
    assert_equal "Gift", bottle.disposal_method
    assert_not bottle.in_inventory?

    assert_difference("Bottle.count", -1) do
      delete bottle_url(bottle)
    end
    assert_redirected_to bottles_url
  end
end
