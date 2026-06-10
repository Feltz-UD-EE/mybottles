require "test_helper"

class DeviseInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "accept invitation displays validation errors" do
    sign_out admin_user

    invited_user = User.invite!(
      {
        email: "invited@example.com",
        name: "Invited User",
        trust_level: "Basic"
      },
      admin_user
    )

    put user_invitation_path, params: {
      user: {
        invitation_token: invited_user.raw_invitation_token,
        password: "short",
        password_confirmation: "short"
      }
    }

    assert_response :unprocessable_entity
    assert_select ".error-messages h2", count: 0
    assert_select ".error-messages", text: /Password is too short \(8 characters minimum\)/
    assert_select ".error-messages", text: /prevented this record from being saved/, count: 0
  end

  test "accept invitation displays password confirmation mismatch plainly" do
    sign_out admin_user

    invited_user = User.invite!(
      {
        email: "mismatch@example.com",
        name: "Mismatch User",
        trust_level: "Basic"
      },
      admin_user
    )

    put user_invitation_path, params: {
      user: {
        invitation_token: invited_user.raw_invitation_token,
        password: "longenough",
        password_confirmation: "different"
      }
    }

    assert_response :unprocessable_entity
    assert_select ".error-messages h2", count: 0
    assert_select ".error-messages", text: /Password confirmation didn't match password/
  end
end
