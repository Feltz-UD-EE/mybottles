require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root renders public home page with layout navigation" do
    sign_out admin_user

    get root_url

    assert_response :success
    assert_select "title", "My Bottles"
    assert_select "h1", "My Bottles"
    assert_select "header .site-logo[href=?]", root_path
    assert_select "nav[aria-label='Main menu']", text: /Reference/
    assert_select "a[href=?]", public_producers_path, text: "Producers"
    assert_select "a[href=?]", public_wines_path, text: "Wines"
    assert_select "a[href=?]", public_regions_path, text: "Regions"
    assert_select "a[href=?]", new_user_session_path, text: "Log in"
    assert_select "footer a[href=?]", about_path, text: "About"
    assert_select "footer a[href=?]", legal_path, text: "Legal"
    assert_select "footer a[href=?]", credits_path, text: "Credits"
    assert_select "footer a[href=?]", signup_path, text: "Signup"
  end

  test "signed in root redirects to private dashboard" do
    get root_url

    assert_redirected_to dashboard_path
  end
end
