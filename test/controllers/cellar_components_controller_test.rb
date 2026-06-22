require "test_helper"

class CellarComponentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cellar = Cellar.create!(name: "Main")
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    @vintage = Vintage.create!(vintage: "2024", wine: wine)
  end

  test "creates bin from preloaded cellar" do
    get new_bin_url(bin: { cellar_id: @cellar.id })

    assert_response :success
    assert_select "select[name='bin[cellar_id]'] option[selected][value=?]", @cellar.id

    assert_difference("Bin.count", 1) do
      post bins_url, params: { bin: { cellar_id: @cellar.id, label: "Everyday Spanish" } }
    end
    assert_redirected_to bin_url(Bin.last)
  end

  test "bay show links to preloaded shelf form" do
    bay = Bay.create!(cellar: @cellar, label: "North")

    get bay_url(bay)

    assert_response :success
    assert_select "a[href=?]", new_shelf_path(shelf: { shelveable_type: "Bay", shelveable_id: bay.id }), "New Shelf"
  end

  test "bay show lists current bottles stored on bay shelves" do
    bay = Bay.create!(cellar: @cellar, label: "North")
    shelf = Shelf.create!(shelveable: bay, number: "5")
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, cellarable: shelf)
    disposed_bottle = Bottle.create!(personal_inventory: "A-002", vintage: @vintage, cellarable: shelf, disposal_date: Date.new(2026, 6, 7), disposal_method: "Drink")

    get bay_url(bay)

    assert_response :success
    assert_select "h2", "Bottles Stored"
    assert_select "a[href=?]", bottle_path(bottle), text: "A-001"
    assert_select "td", "Main Bay North Shelf 5"
    assert_select "td", { text: disposed_bottle.personal_inventory, count: 0 }
  end

  test "bin show lists current bottles stored in bin" do
    bin = Bin.create!(cellar: @cellar, label: "Everyday Spanish")
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, cellarable: bin)

    get bin_url(bin)

    assert_response :success
    assert_select "h2", "Bottles Stored"
    assert_select "a[href=?]", bottle_path(bottle), text: "A-001"
    assert_select "td", "Main - Everyday Spanish"
  end

  test "shelf show lists current bottles stored on shelf" do
    shelf = Shelf.create!(shelveable: @cellar, number: "2")
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, cellarable: shelf)

    get shelf_url(shelf)

    assert_response :success
    assert_select "h1", "Main Shelf 2"
    assert_select "h2", "Bottles Stored"
    assert_select "a[href=?]", bottle_path(bottle), text: "A-001"
    assert_select "td", "Main Shelf 2"
  end

  test "creates shelf from preloaded bay with default depth" do
    bay = Bay.create!(cellar: @cellar, label: "North")

    get new_shelf_url(shelf: { shelveable_type: "Bay", shelveable_id: bay.id })

    assert_response :success
    assert_select "select[name='shelf[shelveable_selection]'] option[selected][value=?]", "Bay:#{bay.id}"
    assert_select "select[name='shelf[depth]'] option[selected][value='Single']", "Single"

    assert_difference("Shelf.count", 1) do
      post shelves_url, params: { shelf: { shelveable_selection: "Bay:#{bay.id}", number: "5", depth: "Multiple" } }
    end

    shelf = Shelf.last
    assert_redirected_to shelf_url(shelf)
    assert_equal "Multiple", shelf.depth
    assert_equal bay, shelf.shelveable
  end
end
