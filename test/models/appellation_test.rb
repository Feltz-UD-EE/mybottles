require "test_helper"

class AppellationTest < ActiveSupport::TestCase
  test "builds a nested path name" do
    country = Country.create!(name: "France", iso2: "FR", iso3: "FRA")
    rhone = Appellation.create!(country: country, name: "Rhône Valley")
    cotes = Appellation.create!(country: country, name: "Côtes-du-Rhône", parent: rhone)
    villages = Appellation.create!(country: country, name: "Côtes-du-Rhône Villages", parent: cotes)

    assert_equal "Rhône Valley - Côtes-du-Rhône - Côtes-du-Rhône Villages", villages.path_name
  end
end
