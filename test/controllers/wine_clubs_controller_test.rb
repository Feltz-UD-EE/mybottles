require "test_helper"

class WineClubsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @producer = Producer.create!(name: "Producer")
  end

  test "lists current clubs with dynamic table UI" do
    current = WineClub.create!(producer: @producer, tier: "Reserve", size: 6, schedule: "Spring and fall")
    WineClub.create!(producer: @producer, tier: "Past", size: 3, schedule: "Quarterly", date_left: Date.new(2026, 6, 7))

    get wine_clubs_url

    assert_response :success
    assert_select "h1", "Current Clubs"
    assert_select "[data-controller='table']"
    assert_select "a[href=?]", wine_club_path(current), "Reserve"
    assert_select "td", text: "Past", count: 0
  end

  test "lists all clubs" do
    WineClub.create!(producer: @producer, tier: "Reserve", size: 6, schedule: "Spring and fall")
    WineClub.create!(producer: @producer, tier: "Past", size: 3, schedule: "Quarterly", date_left: Date.new(2026, 6, 7))

    get all_wine_clubs_url

    assert_response :success
    assert_select "h1", "All Clubs"
    assert_select "td", "Reserve"
    assert_select "td", "Past"
    assert_select "td", "Yes"
    assert_select "td", "No"
  end

  test "new renders producer selector and inline new producer panel" do
    get new_wine_club_url

    assert_response :success
    assert_select "select[name='wine_club[producer_id]']"
    assert_select "label[for='wine_club_member_id']", "Member ID"
    assert_select "button", "New Producer"
    assert_select "[data-wine-club-target='newProducerFields'][hidden]"
  end

  test "creates updates and deletes wine club" do
    assert_difference("WineClub.count", 1) do
      post wine_clubs_url, params: {
        wine_club: {
          producer_id: @producer.id,
          tier: "Reserve",
          size: 6,
          schedule: "Spring and fall",
          delivery_method: "Pickup",
          payment_method: "Card",
          discount: "15.0"
        }
      }
    end

    club = WineClub.order(:created_at).last
    assert_redirected_to wine_club_url(club)

    patch wine_club_url(club), params: {
      wine_club: {
        producer_id: @producer.id,
        tier: "Estate",
        size: 12,
        schedule: "Quarterly"
      }
    }

    assert_redirected_to wine_club_url(club)
    assert_equal "Estate", club.reload.tier
    assert_equal 12, club.size

    assert_difference("WineClub.count", -1) do
      delete wine_club_url(club)
    end
    assert_redirected_to wine_clubs_url
  end

  test "creates producer inline when creating wine club" do
    assert_difference("Producer.count", 1) do
      assert_difference("WineClub.count", 1) do
        post wine_clubs_url, params: {
          wine_club: {
            tier: "Gold",
            size: 4,
            schedule: "Quarterly"
          },
          new_producer: {
            name: "New Producer",
            email: "club@example.com"
          }
        }
      end
    end

    club = WineClub.order(:created_at).last
    assert_redirected_to wine_club_url(club)
    assert_equal "New Producer", club.producer.name
  end
end
