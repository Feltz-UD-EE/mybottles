require "test_helper"

class VintagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    producer = Producer.create!(name: "Producer")
    @wine = Wine.create!(name: "Estate Red", producer: producer)
  end

  test "lists vintages with dynamic table UI" do
    vintage = Vintage.create!(vintage: "2024", wine: @wine, grapes: "Cabernet Sauvignon")
    TastingNote.create!(tasteable: vintage, date: Date.new(2026, 6, 8), overall: "Bright")

    get vintages_url

    assert_response :success
    assert_select "h1", "Vintages"
    assert_select "[data-controller='table']"
    assert_select "tbody tr", text: /Producer\s+Estate Red\s+2024/
    assert_select "a[href=?]", vintage_path(Vintage.last), "2024"
    assert_select "th", "Tasted"
    assert_select "span.tasted-checkmark[aria-label='Tasted']", count: 1
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

  test "new preloads wine from params" do
    get new_vintage_url(vintage: { wine_id: @wine.id })

    assert_response :success
    assert_select ".resource-form .field:first-child label", "Wine"
    assert_select "select[name='vintage[wine_id]'] option[selected][value=?]", @wine.id
    assert_select "select[name='vintage[wine_id]'] option", "Producer - Estate Red"
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
    assert_select "a[href=?]", new_bottle_path(bottle: { vintage_id: vintage.id }), text: "New Bottle"
  end

  test "show lists tasting notes across all vintages for the wine" do
    vintage_2023 = Vintage.create!(vintage: "2023", wine: @wine)
    vintage_2024 = Vintage.create!(vintage: "2024", wine: @wine)
    bottle_2023 = Bottle.create!(personal_inventory: "A-023", vintage: vintage_2023)
    bottle_2024 = Bottle.create!(personal_inventory: "A-024", vintage: vintage_2024)
    other_wine = Wine.create!(name: "Other Wine", producer: @wine.producer)
    other_vintage = Vintage.create!(vintage: "2025", wine: other_wine)
    TastingNote.create!(tasteable: bottle_2023, date: Date.new(2026, 6, 1), overall: "Older vintage bottle", rating: 2.5)
    TastingNote.create!(tasteable: vintage_2024, date: Date.new(2026, 6, 2), overall: "Newer vintage note", rating: 4.0)
    TastingNote.create!(tasteable: bottle_2024, date: Date.new(2026, 6, 3), overall: "Newer vintage bottle", rating: 4.75)
    TastingNote.create!(tasteable: other_vintage, date: Date.new(2026, 6, 4), overall: "Other wine note", rating: 5.0)

    get vintage_url(vintage_2023)

    assert_response :success
    assert_select "dt", "Average rating"
    assert_select ".rating-circles[title='3.75'][aria-label='Average rating 3.75 out of 5']"
    assert_select "h2", "Tasting Notes"
    assert_select "th", "Rating"
    assert_select "td", "Older vintage bottle"
    assert_select "td", "Newer vintage note"
    assert_select "td", "Newer vintage bottle"
    assert_select "td", text: "Other wine note", count: 0
    assert_operator response.body.index("Newer vintage bottle"), :<, response.body.index("Newer vintage note")
    assert_operator response.body.index("Newer vintage note"), :<, response.body.index("Older vintage bottle")
  end
end
