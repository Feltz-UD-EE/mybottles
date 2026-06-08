require "test_helper"

class CellarTest < ActiveSupport::TestCase
  setup do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    @vintage = Vintage.create!(vintage: "2024", wine: wine)
  end

  test "counts current bottles stored directly and through nested locations" do
    cellar = Cellar.create!(name: "Main")
    bin = Bin.create!(cellar: cellar, label: "Everyday Spanish")
    bay = Bay.create!(cellar: cellar, label: "North")
    direct_shelf = Shelf.create!(shelveable: cellar, number: "2")
    bay_shelf = Shelf.create!(shelveable: bay, number: "5")

    Bottle.create!(vintage: @vintage, cellarable: cellar)
    Bottle.create!(vintage: @vintage, cellarable: bin)
    Bottle.create!(vintage: @vintage, cellarable: direct_shelf)
    Bottle.create!(vintage: @vintage, cellarable: bay_shelf)
    Bottle.create!(vintage: @vintage, cellarable: bay_shelf, disposal_date: Date.new(2026, 6, 8), disposal_method: "Drink")

    assert_equal 4, cellar.current_bottle_count
    assert_equal 1, bin.current_bottle_count
    assert_equal 1, bay.current_bottle_count
    assert_equal 1, direct_shelf.current_bottle_count
  end
end
