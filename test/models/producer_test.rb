require "test_helper"

class ProducerTest < ActiveSupport::TestCase
  test "requires a name and validates contact formats" do
    producer = Producer.new(name: "", email: "not-an-email", website: "ftp://example.com")

    assert_not producer.valid?
    assert_includes producer.errors[:name], "can't be blank"
    assert_includes producer.errors[:email], "is invalid"
    assert_includes producer.errors[:website], "is invalid"
  end

  test "uses uuid primary keys" do
    producer = Producer.create!(name: "Château Exemple")

    assert_match(/\A[0-9a-f-]{36}\z/, producer.id)
  end

  test "does not destroy when wines exist" do
    producer = Producer.create!(name: "Producer")
    Wine.create!(name: "Estate Red", producer: producer)

    assert_no_difference("Producer.count") do
      assert_not producer.destroy
    end
  end

  test "counts bottles currently in inventory through wines and vintages" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    Bottle.create!(vintage: vintage, disposal_method: "Drink")
    Bottle.create!(vintage: vintage, disposal_date: Date.new(2026, 6, 7), disposal_method: "Drink")

    assert_equal 2, producer.bottles.count
    assert_equal 1, producer.bottles_in_inventory_count
  end
end
