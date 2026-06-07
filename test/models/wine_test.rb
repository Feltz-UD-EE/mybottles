require "test_helper"

class WineTest < ActiveSupport::TestCase
  test "validates enum values and supports diacritics" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.new(name: "Rosé Reserve", producer: producer, style: "Still", color: "Rosé")

    assert wine.valid?

    wine.style = "other"
    wine.color = "pink"

    assert_not wine.valid?
    assert_includes wine.errors[:style], "is not included in the list"
    assert_includes wine.errors[:color], "is not included in the list"
  end

  test "does not allow producer changes" do
    original = Producer.create!(name: "Original")
    replacement = Producer.create!(name: "Replacement")
    wine = Wine.create!(name: "Estate Red", producer: original)

    wine.producer = replacement

    assert_not wine.valid?
    assert_includes wine.errors[:producer_id], "cannot be changed"
  end

  test "does not destroy when vintages exist" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    Vintage.create!(vintage: "2024", wine: wine)

    assert_no_difference("Wine.count") do
      assert_not wine.destroy
    end
  end
end
