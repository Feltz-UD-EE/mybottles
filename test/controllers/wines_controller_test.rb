require "test_helper"

class WinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @producer = Producer.create!(name: "Producer")
  end

  test "lists wines with top-level resource page" do
    wine = Wine.create!(name: "Estate Rosé", producer: @producer, style: "Still", color: "Rosé")
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    TastingNote.create!(tasteable: vintage, date: Date.new(2026, 6, 8), overall: "Bright")

    get wines_url

    assert_response :success
    assert_select "h1", "Wines"
    assert_select "[data-controller='table']"
    assert_select "tbody tr:first-child td:first-child", "Producer"
    assert_select "a[href=?]", wine_path(wine), "Estate Rosé"
    assert_select "th", "Tasted"
    assert_select "span.tasted-checkmark[aria-label='Tasted']", count: 1
    assert_select "td.actions a", text: "Show", count: 0
    assert_select "a[href=?]", new_watch_list_entry_path(watch_list_entry: { watchable_type: "Wine", watchable_id: wine.id }), text: "Add to Watch List"
  end

  test "creates updates and blocks producer changes" do
    assert_difference("Wine.count", 1) do
      post wines_url, params: { wine: { name: "Estate Red", producer_id: @producer.id, style: "Still", color: "Red" } }
    end

    wine = Wine.order(:created_at).last
    assert_redirected_to wine_url(wine)

    patch wine_url(wine), params: { wine: { name: "Estate White", producer_id: @producer.id, style: "Still", color: "White" } }
    assert_redirected_to wine_url(wine)
    assert_equal "Estate White", wine.reload.name

    other_producer = Producer.create!(name: "Other Producer")
    patch wine_url(wine), params: { wine: { producer_id: other_producer.id } }
    assert_response :unprocessable_entity
  end

  test "new preloads producer from params" do
    get new_wine_url(wine: { producer_id: @producer.id })

    assert_response :success
    assert_select ".resource-form .field:first-child label", "Producer"
    assert_select "select[name='wine[producer_id]'] option[selected][value=?]", @producer.id
    assert_select "select[name='wine[style]'] option[selected][value='Still']", "Still"
  end

  test "show displays bottle purchase counts by vintage" do
    wine = Wine.create!(name: "Estate Red", producer: @producer)
    vintage_2023 = Vintage.create!(vintage: "2023", wine: wine)
    vintage_2024 = Vintage.create!(vintage: "2024", wine: wine)
    Bottle.create!(vintage: vintage_2023, disposal_method: "Drink")
    2.times { Bottle.create!(vintage: vintage_2024, disposal_method: "Drink") }
    Bottle.create!(vintage: vintage_2024, disposal_date: Date.new(2026, 6, 7), disposal_method: "Drink")

    get wine_url(wine)

    assert_response :success
    assert_select "h1", "Producer - Estate Red"
    assert_select "a[href=?]", new_watch_list_entry_path(watch_list_entry: { watchable_type: "Wine", watchable_id: wine.id }), text: "Add to Watch List"
    assert_select "a[href=?]", new_vintage_path(vintage: { wine_id: wine.id }), text: "New Vintage"
    assert_select "h2", "Bottles Purchased by Vintage"
    assert_select "tr", text: /2023\s+1\s+1/
    assert_select "tr", text: /2024\s+3\s+2/
  end

  test "show lists tasting notes across all vintages sorted by vintage and date descending" do
    wine = Wine.create!(name: "Estate Red", producer: @producer)
    vintage_2023 = Vintage.create!(vintage: "2023", wine: wine)
    vintage_2024 = Vintage.create!(vintage: "2024", wine: wine)
    bottle_2023 = Bottle.create!(personal_inventory: "A-023", vintage: vintage_2023)
    bottle_2024 = Bottle.create!(personal_inventory: "A-024", vintage: vintage_2024)
    other_wine = Wine.create!(name: "Other Wine", producer: @producer)
    other_vintage = Vintage.create!(vintage: "2025", wine: other_wine)
    TastingNote.create!(tasteable: bottle_2023, date: Date.new(2026, 6, 1), overall: "Older vintage bottle", rating: 2.5)
    TastingNote.create!(tasteable: vintage_2024, date: Date.new(2026, 6, 2), overall: "Newer vintage note", rating: 4.0)
    TastingNote.create!(tasteable: bottle_2024, date: Date.new(2026, 6, 3), overall: "Newer vintage bottle", rating: 4.75)
    TastingNote.create!(tasteable: other_vintage, date: Date.new(2026, 6, 4), overall: "Other wine note", rating: 5.0)

    get wine_url(wine)

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
