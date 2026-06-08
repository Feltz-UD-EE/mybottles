require "test_helper"

class CellarComponentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cellar = Cellar.create!(name: "Main")
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
