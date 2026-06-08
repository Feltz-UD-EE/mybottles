require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root renders public home page with layout navigation" do
    get root_url

    assert_response :success
    assert_select "title", "My Bottles"
    assert_select "h1", "Welcome to My Bottles!"
    assert_select "header .site-logo[href=?]", root_path
    assert_select "nav[aria-label='Main menu']", text: /Cellars/
    assert_select "a[href=?]", cellars_path, text: "Cellars"
    assert_select "button[data-action='theme#toggle']", text: /Dark mode/
    assert_select "footer a[href=?]", about_path, text: "About"
    assert_select "footer a[href=?]", legal_path, text: "Legal"
    assert_select "footer a[href=?]", credits_path, text: "Credits"
    assert_select "footer a[href=?]", signup_path, text: "Signup"
  end
end
