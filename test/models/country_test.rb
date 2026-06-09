require "test_helper"

class CountryTest < ActiveSupport::TestCase
  test "requires identifying fields but allows blank notes" do
    country = Country.new

    assert_not country.valid?
    assert_includes country.errors[:name], "can't be blank"
    assert_includes country.errors[:iso2], "can't be blank"
    assert_includes country.errors[:iso3], "can't be blank"

    country.assign_attributes(name: "France", iso2: "FR", iso3: "FRA")
    assert country.valid?
    assert_nil country.notes
  end

  test "counts named regions" do
    country = Country.create!(name: "France", iso2: "FR", iso3: "FRA")
    Appellation.create!(country: country, name: "Bordeaux")
    Appellation.create!(country: country, name: "Médoc")

    assert_equal 2, country.named_region_count
  end
end
