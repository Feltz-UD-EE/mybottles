require "test_helper"

class CellarsControllerTest < ActionDispatch::IntegrationTest
  test "lists cellars with dynamic table UI and menu links" do
    cellar = Cellar.create!(name: "Main", location: "Basement")

    get cellars_url

    assert_response :success
    assert_select "h1", "Cellars"
    assert_select "[data-controller='table']"
    assert_select "a[href=?]", cellar_path(cellar), "Main"
    assert_select "a[href=?]", bins_path, "Bins"
    assert_select "a[href=?]", bays_path, "Bays"
    assert_select "a[href=?]", shelves_path, "Shelves"
  end

  test "show displays counts and new child buttons" do
    cellar = Cellar.create!(name: "Main")

    get cellar_url(cellar)

    assert_response :success
    assert_select "dt", "Bottles stored"
    assert_select "dd", "0"
    assert_select "a[href=?]", new_bin_path(bin: { cellar_id: cellar.id }), "New Bin"
    assert_select "a[href=?]", new_bay_path(bay: { cellar_id: cellar.id }), "New Bay"
    assert_select "a[href=?]", new_shelf_path(shelf: { shelveable_type: "Cellar", shelveable_id: cellar.id }), "New Shelf"
  end

  test "creates updates and deletes cellar" do
    assert_difference("Cellar.count", 1) do
      post cellars_url, params: { cellar: { name: "Main", location: "Basement", notes: "Cool." } }
    end

    cellar = Cellar.order(:created_at).last
    assert_redirected_to cellar_url(cellar)

    patch cellar_url(cellar), params: { cellar: { name: "Updated Main" } }
    assert_redirected_to cellar_url(cellar)
    assert_equal "Updated Main", cellar.reload.name

    assert_difference("Cellar.count", -1) do
      delete cellar_url(cellar)
    end
    assert_redirected_to cellars_url
  end
end
