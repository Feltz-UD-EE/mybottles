require "test_helper"

class GrapesControllerTest < ActionDispatch::IntegrationTest
  test "lists grapes with dynamic table UI" do
    grape = Grape.create!(name: "Cabernet Sauvignon")

    get grapes_url

    assert_response :success
    assert_select "h1", "Grapes"
    assert_select "[data-controller='table']"
    assert_select "a[href=?]", grape_path(grape), "Cabernet Sauvignon"
  end

  test "show displays synonyms and allowed appellations" do
    france = Country.create!(name: "France", iso2: "FR", iso3: "FRA")
    bordeaux = Appellation.create!(country: france, name: "Bordeaux")
    syrah = Grape.create!(name: "Syrah")
    shiraz = Grape.create!(name: "Shiraz")
    GrapeSynonym.create!(grape: syrah, synonym_grape: shiraz)
    AppellationGrape.create!(appellation: bordeaux, grape: shiraz, notes: "Allowed through synonym test")

    get grape_url(syrah)

    assert_response :success
    assert_select "h1", /Syrah/
    assert_select "a[href=?]", grape_path(shiraz), "Shiraz"
    assert_select "a[href=?]", region_path(bordeaux), "Bordeaux"
    assert_select "td", "Via Shiraz"
  end

  test "creates updates and deletes grape" do
    assert_difference("Grape.count", 1) do
      post grapes_url, params: { grape: { name: "Merlot", notes: "Bordeaux grape" } }
    end

    grape = Grape.order(:created_at).last
    assert_redirected_to grape_url(grape)

    patch grape_url(grape), params: { grape: { name: "Merlot", notes: "Updated notes" } }
    assert_redirected_to grape_url(grape)
    assert_equal "Updated notes", grape.reload.notes

    assert_difference("Grape.count", -1) do
      delete grape_url(grape)
    end
    assert_redirected_to grapes_url
  end
end
