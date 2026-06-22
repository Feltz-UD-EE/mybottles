require "test_helper"

class BottleLocationTest < ActiveSupport::TestCase
  setup do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    @vintage = Vintage.create!(vintage: "2024", wine: wine)
  end

  test "formats bottle locations" do
    beach_house = Cellar.create!(name: "Beach House")
    bay = Bay.create!(cellar: beach_house, label: "North")
    bay_shelf = Shelf.create!(shelveable: bay, number: "5", label: "Aging Reds")
    main = Cellar.create!(name: "Main")
    bin = Bin.create!(cellar: main, location: "3", label: "Everyday Spanish")
    fridge = Cellar.create!(name: "Fridge 1")
    cellar_shelf = Shelf.create!(shelveable: fridge, number: "2", label: "Whites")
    bar_fridge = Cellar.create!(name: "Bar Fridge")

    assert_equal "Beach House Bay North Shelf 5", Bottle.create!(vintage: @vintage, cellarable: bay_shelf).location_name
    assert_equal "Main - Everyday Spanish", Bottle.create!(vintage: @vintage, cellarable: bin).location_name
    assert_equal "Fridge 1 Shelf 2", Bottle.create!(vintage: @vintage, cellarable: cellar_shelf).location_name
    assert_equal "Bar Fridge", Bottle.create!(vintage: @vintage, cellarable: bar_fridge).location_name
    assert_equal "Not Cellared", Bottle.create!(vintage: @vintage).location_name
  end

  test "formats cellar dropdown names for bins and shelves" do
    cellar = Cellar.create!(name: "Main")
    bin = Bin.create!(cellar: cellar, location: "3", label: "Everyday Spanish")
    bay = Bay.create!(cellar: cellar, label: "North")
    bay_shelf = Shelf.create!(shelveable: bay, number: "5", label: "Aging Reds")
    cellar_shelf = Shelf.create!(shelveable: cellar, number: "2", label: "Whites")

    assert_equal "Bin 3 - Everyday Spanish", bin.cellarable_selection_name
    assert_equal "Main Bay North Shelf 5 - Aging Reds", bay_shelf.cellarable_selection_name
    assert_equal "Main Shelf 2 - Whites", cellar_shelf.cellarable_selection_name
  end
end
