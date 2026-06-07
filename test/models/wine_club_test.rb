require "test_helper"

class WineClubTest < ActiveSupport::TestCase
  test "validates required fields enums and discount range" do
    club = WineClub.new(size: nil, schedule: "", delivery_method: "Delivery", discount: 101)

    assert_not club.valid?
    assert_includes club.errors[:producer], "must exist"
    assert_includes club.errors[:size], "can't be blank"
    assert_includes club.errors[:schedule], "can't be blank"
    assert_includes club.errors[:delivery_method], "is not included in the list"
    assert_includes club.errors[:discount], "must be less than or equal to 100"
  end

  test "tracks current membership from date left" do
    producer = Producer.create!(name: "Producer")
    club = WineClub.create!(producer: producer, size: 6, schedule: "Spring and fall", delivery_method: "Pickup", discount: 15)

    assert club.current_member?
    assert_equal "Producer", club.display_name

    club.update!(tier: "Reserve", date_left: Date.new(2026, 6, 7))

    assert_not club.current_member?
    assert_equal "Producer - Reserve", club.display_name
  end
end
