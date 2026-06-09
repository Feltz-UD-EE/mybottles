require "test_helper"

class GrapeTest < ActiveSupport::TestCase
  test "requires a name but does not require unique names" do
    Grape.create!(name: "Malvasia", notes: "First distinct grape")
    duplicate_name = Grape.new(name: "Malvasia", notes: "Second distinct grape")

    assert duplicate_name.valid?
  end

  test "prevents duplicate inverse synonym relationships" do
    syrah = Grape.create!(name: "Syrah")
    shiraz = Grape.create!(name: "Shiraz")
    GrapeSynonym.create!(grape: syrah, synonym_grape: shiraz)

    inverse = GrapeSynonym.new(grape: shiraz, synonym_grape: syrah)

    assert_not inverse.valid?
  end

  test "prevents self synonym relationships" do
    syrah = Grape.create!(name: "Syrah")
    synonym = GrapeSynonym.new(grape: syrah, synonym_grape: syrah)

    assert_not synonym.valid?
  end

  test "includes appellations through synonyms" do
    france = Country.create!(name: "France", iso2: "FR", iso3: "FRA")
    bordeaux = Appellation.create!(country: france, name: "Bordeaux")
    syrah = Grape.create!(name: "Syrah")
    shiraz = Grape.create!(name: "Shiraz")
    GrapeSynonym.create!(grape: syrah, synonym_grape: shiraz)
    AppellationGrape.create!(appellation: bordeaux, grape: shiraz)

    assert_equal [ bordeaux ], syrah.allowed_appellations_with_source.map(&:first)
    assert_equal "Via Shiraz", syrah.allowed_appellations_with_source.first.second
  end
end
