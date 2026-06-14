require "test_helper"

class BottleTest < ActiveSupport::TestCase
  test "requires vintage and validates price values" do
    bottle = Bottle.new(list_price: -1, discount_price: -2)

    assert_not bottle.valid?
    assert_includes bottle.errors[:vintage], "must exist"
    assert_includes bottle.errors[:list_price], "must be greater than or equal to 0"
    assert_includes bottle.errors[:discount_price], "must be greater than or equal to 0"
    assert_empty bottle.errors[:disposal_method]
  end

  test "allows blank disposal method and validates provided disposal methods" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    bottle = Bottle.new(vintage: vintage, disposal_method: "")

    assert bottle.valid?
    assert_nil bottle.disposal_method

    bottle.disposal_method = "Other"

    assert_not bottle.valid?
    assert_includes bottle.errors[:disposal_method], "is not included in the list"
  end

  test "formats display name from inventory and vintage" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: vintage, disposal_method: "Drink")

    assert_equal "A-001 - Estate Red 2024", bottle.to_s
  end

  test "generates auto inventory when personal inventory is blank" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)

    first_bottle = Bottle.create!(vintage: vintage)
    second_bottle = Bottle.create!(personal_inventory: "", vintage: vintage)

    assert_equal "000001", first_bottle.auto_inventory
    assert_equal "000-001", first_bottle.inventory_code
    assert_equal "000001", first_bottle.auto_inventory_display.delete("-")
    assert_equal "000002", second_bottle.auto_inventory
    assert_equal "000-002", second_bottle.auto_inventory_display
    assert_equal 3, admin_user.reload.next_auto_inventory_number
  end

  test "uses personal inventory before generated inventory for display" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: vintage)

    assert_nil bottle.auto_inventory
    assert_equal "A-001", bottle.inventory_code
  end

  test "tracks inventory status from disposal date" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    bottle = Bottle.create!(vintage: vintage, disposal_method: "Drink")

    assert bottle.in_inventory?

    bottle.update!(disposal_date: Date.new(2026, 6, 7))

    assert_not bottle.in_inventory?
  end

  test "requires disposal date on or after purchase date" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    bottle = Bottle.new(vintage: vintage, disposal_method: "Drink", purchase_date: Date.new(2026, 6, 6), disposal_date: Date.new(2026, 6, 6))

    assert bottle.valid?

    bottle.disposal_date = Date.new(2026, 6, 5)

    assert_not bottle.valid?
    assert_includes bottle.errors[:disposal_date], "must be on or after purchase date"
  end
end
