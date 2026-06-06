require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "about page renders project purpose from README context" do
    get about_url

    assert_response :success
    assert_select "h1", "About My Bottles"
    assert_select "li", text: "Keep track of wine purchases and inventory."
    assert_select "li", text: "Manage tasting notes for bottles in the cellar and wines tasted elsewhere."
  end

  test "legal page renders generic rights and disclaimer language" do
    get legal_url

    assert_response :success
    assert_select "h1", "Legal"
    assert_select "p", text: /All rights reserved/
    assert_select "p", text: /provided as-is/
  end

  test "credits page renders placeholders" do
    get credits_url

    assert_response :success
    assert_select "h1", "Credits"
    assert_select "li", text: "Application design and development: placeholder."
  end

  test "signup page renders closed beta message" do
    get signup_url

    assert_response :success
    assert_select "h1", "Signup"
    assert_select "p", text: /closed beta/
    assert_select ".placeholder-text", "interest@example.com"
  end
end
