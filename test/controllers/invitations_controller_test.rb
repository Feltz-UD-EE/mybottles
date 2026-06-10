require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "curator can access invite user page" do
    sign_in users(:curator)

    get new_invitation_path

    assert_response :success
    assert_select "h1", "Invite User"
  end

  test "basic user cannot access invite user page" do
    sign_in users(:basic)

    get new_invitation_path

    assert_redirected_to root_path
    assert_equal "You are not authorized to do that.", flash[:alert]
  end
end
