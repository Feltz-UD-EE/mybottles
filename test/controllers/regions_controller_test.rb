require "test_helper"

class RegionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @france = Country.create!(name: "France", iso2: "FR", iso3: "FRA")
    @spain = Country.create!(name: "Spain", iso2: "ES", iso3: "ESP")
  end

  test "lists regions with dynamic table UI and supports country filtering" do
    bordeaux = Appellation.create!(country: @france, name: "Bordeaux", degree: "AOC")
    Appellation.create!(country: @spain, name: "Rioja", degree: "DOCa")

    get regions_url(country_id: @france.id)

    assert_response :success
    assert_select "h1", "France Regions"
    assert_select "[data-controller='table']"
    assert_select "a[href=?]", region_path(bordeaux), "Bordeaux"
    assert_select "td", text: "Rioja", count: 0
  end

  test "show displays child regions recursively" do
    rhone = Appellation.create!(country: @france, name: "Rhône Valley")
    cotes = Appellation.create!(country: @france, name: "Côtes-du-Rhône", parent: rhone)
    villages = Appellation.create!(country: @france, name: "Côtes-du-Rhône Villages", parent: cotes)

    get region_url(rhone)

    assert_response :success
    assert_select "h1", "Rhône Valley"
    assert_select "a[href=?]", new_region_path(appellation: { country_id: @france.id, parent_id: rhone.id }), "New Child Region"
    assert_select "a[href=?]", region_path(cotes), "Côtes-du-Rhône"
    assert_select "a[href=?]", region_path(villages), "Côtes-du-Rhône Villages"
  end

  test "new preloads country and parent" do
    parent = Appellation.create!(country: @france, name: "Bordeaux")

    get new_region_url(appellation: { country_id: @france.id, parent_id: parent.id })

    assert_response :success
    assert_select "select[name='appellation[country_id]'] option[selected][value=?]", @france.id
    assert_select "select[name='appellation[parent_id]'] option[selected][value=?]", parent.id
  end

  test "new preloads country from country id" do
    get new_region_url(country_id: @france.id)

    assert_response :success
    assert_select "select[name='appellation[country_id]'] option[selected][value=?]", @france.id
  end

  test "creates updates and deletes region" do
    assert_difference("Appellation.count", 1) do
      post regions_url, params: { appellation: { country_id: @france.id, name: "Bordeaux", degree: "AOC", auto_generated: "1" } }
    end

    region = Appellation.order(:created_at).last
    assert_redirected_to region_url(region)
    assert region.auto_generated?

    patch region_url(region), params: { appellation: { country_id: @france.id, name: "Updated Bordeaux", auto_generated: "0" } }
    assert_redirected_to region_url(region)
    assert_equal "Updated Bordeaux", region.reload.name
    assert_not region.auto_generated?

    assert_difference("Appellation.count", -1) do
      delete region_url(region)
    end
    assert_redirected_to regions_url
  end
end
