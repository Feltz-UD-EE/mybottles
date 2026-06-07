require "test_helper"

class ProducersControllerTest < ActionDispatch::IntegrationTest
  test "lists producers with dynamic table UI" do
    producer = Producer.create!(name: "Château Exemple", email: "info@example.com", website: "https://example.com")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    Bottle.create!(vintage: vintage, disposal_method: "Drink")

    get producers_url

    assert_response :success
    assert_select "h1", "Producers"
    assert_select "[data-controller='table']"
    assert_select "a[href=?]", producer_path(producer), "Château Exemple"
    assert_select "th", "Bottles on hand"
    assert_select "td", "1"
    assert_select "td.actions", false
  end

  test "show displays a minimal wine table" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer, style: "Still", color: "Red", appellation: "Old Mission Peninsula")

    get producer_url(producer)

    assert_response :success
    assert_select "h2", "Wines"
    assert_select "a[href=?]", wine_path(wine), "Estate Red"
  end

  test "creates updates and deletes producer" do
    assert_difference("Producer.count", 1) do
      post producers_url, params: { producer: { name: "New Producer", email: "info@example.com", website: "https://example.com" } }
    end

    producer = Producer.order(:created_at).last
    assert_redirected_to producer_url(producer)

    patch producer_url(producer), params: { producer: { name: "Updated Producer" } }
    assert_redirected_to producer_url(producer)
    assert_equal "Updated Producer", producer.reload.name

    assert_difference("Producer.count", -1) do
      delete producer_url(producer)
    end
    assert_redirected_to producers_url
  end
end
