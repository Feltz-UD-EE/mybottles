require "test_helper"

class VintagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    producer = Producer.create!(name: "Producer")
    @wine = Wine.create!(name: "Estate Red", producer: producer)
  end

  test "lists vintages with dynamic table UI" do
    Vintage.create!(vintage: "2024", wine: @wine, grapes: "Cabernet Sauvignon")

    get vintages_url

    assert_response :success
    assert_select "h1", "Vintages"
    assert_select "[data-controller='table']"
    assert_select "tbody tr:first-child td:first-child", "Producer"
    assert_select "tbody tr:first-child td:nth-child(2)", "Estate Red"
    assert_select "a[href=?]", vintage_path(Vintage.last), "2024"
    assert_select "a[href=?]", new_watch_list_entry_path(watch_list_entry: { watchable_type: "Vintage", watchable_id: Vintage.last.id }), text: "Add to Watch List"
  end

  test "creates updates and deletes vintage" do
    assert_difference("Vintage.count", 1) do
      post vintages_url, params: { vintage: { vintage: "2024", wine_id: @wine.id, grapes: "Cabernet Sauvignon" } }
    end

    vintage = Vintage.order(:created_at).last
    assert_redirected_to vintage_url(vintage)

    patch vintage_url(vintage), params: { vintage: { vintage: "non-vintage", wine_id: @wine.id } }
    assert_redirected_to vintage_url(vintage)
    assert_equal "non-vintage", vintage.reload.vintage

    assert_difference("Vintage.count", -1) do
      delete vintage_url(vintage)
    end
    assert_redirected_to vintages_url
  end

  test "show displays bottle purchase count" do
    vintage = Vintage.create!(vintage: "2024", wine: @wine)
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: vintage, purchase_date: Date.new(2026, 6, 6), disposal_method: "Drink")
    Bottle.create!(vintage: vintage, disposal_method: "Drink")

    get vintage_url(vintage)

    assert_response :success
    assert_select "h1", "Producer - Estate Red - 2024"
    assert_select "a[href=?]", new_watch_list_entry_path(watch_list_entry: { watchable_type: "Vintage", watchable_id: vintage.id }), text: "Add to Watch List"
    assert_select "dt", "Bottles purchased"
    assert_select "dd", "2"
    assert_select "h2", "Bottles Purchased"
    assert_select "a[href=?]", bottle_path(bottle), "A-001"
  end
end
