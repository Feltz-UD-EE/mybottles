require "test_helper"

class CountriesControllerTest < ActionDispatch::IntegrationTest
  test "lists countries with dynamic table UI and named region counts" do
    country = Country.create!(name: "France", fullname: "French Republic", iso2: "FR", iso3: "FRA")
    Appellation.create!(country: country, name: "Bordeaux")

    get countries_url

    assert_response :success
    assert_select "h1", "Countries"
    assert_select "[data-controller='table']"
    assert_select "a[href=?]", country_path(country), "France"
    assert_select "th", "Named regions:"
    assert_select "td", "1"
  end

  test "show displays regions and link to country filtered regions list" do
    country = Country.create!(name: "France", iso2: "FR", iso3: "FRA")
    parent = Appellation.create!(country: country, name: "Rhône Valley")
    child = Appellation.create!(country: country, name: "Côtes-du-Rhône", parent: parent)

    get country_url(country)

    assert_response :success
    assert_select "a[href=?]", new_region_path(country_id: country.id), count: 2
    assert_select "a[href=?]", regions_path(country_id: country.id), "All regions"
    assert_select "a[href=?]", region_path(parent), "Rhône Valley"
    assert_select "a[href=?]", region_path(child), "Côtes-du-Rhône"
  end

  test "creates updates and deletes country" do
    assert_difference("Country.count", 1) do
      post countries_url, params: { country: { name: "France", fullname: "French Republic", iso2: "FR", iso3: "FRA" } }
    end

    country = Country.order(:created_at).last
    assert_redirected_to country_url(country)

    patch country_url(country), params: { country: { name: "Updated France" } }
    assert_redirected_to country_url(country)
    assert_equal "Updated France", country.reload.name

    assert_difference("Country.count", -1) do
      delete country_url(country)
    end
    assert_redirected_to countries_url
  end
end
