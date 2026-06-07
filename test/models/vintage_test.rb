require "test_helper"

class VintageTest < ActiveSupport::TestCase
  test "requires vintage and wine" do
    vintage = Vintage.new(vintage: "")

    assert_not vintage.valid?
    assert_includes vintage.errors[:vintage], "can't be blank"
    assert_includes vintage.errors[:wine], "must exist"
  end

  test "does not destroy when bottles exist" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    Bottle.create!(vintage: vintage, disposal_method: "Drink")

    assert_no_difference("Vintage.count") do
      assert_not vintage.destroy
    end
  end
end
