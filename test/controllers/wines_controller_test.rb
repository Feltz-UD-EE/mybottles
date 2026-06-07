require "test_helper"

class WinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @producer = Producer.create!(name: "Producer")
  end

  test "lists wines with top-level resource page" do
    wine = Wine.create!(name: "Estate Rosé", producer: @producer, style: "Still", color: "Rosé")

    get wines_url

    assert_response :success
    assert_select "h1", "Wines"
    assert_select "[data-controller='table']"
    assert_select "tbody tr:first-child td:first-child", "Producer"
    assert_select "a[href=?]", wine_path(wine), "Estate Rosé"
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
    assert_select "h2", "Bottles Purchased by Vintage"
    assert_select "tr", text: /2023\s+1\s+1/
    assert_select "tr", text: /2024\s+3\s+2/
  end
end
