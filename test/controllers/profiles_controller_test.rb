require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "show lists pending and accepted invitations sent by current user" do
    pending_invitation = User.invite!(
      {
        email: "pending-invite@example.com",
        name: "Pending Invite",
        trust_level: "Basic"
      },
      admin_user
    )
    accepted_invitation = User.invite!(
      {
        email: "accepted-invite@example.com",
        name: "Accepted Invite",
        trust_level: "Basic"
      },
      admin_user
    )
    User.accept_invitation!(
      invitation_token: accepted_invitation.raw_invitation_token,
      password: "password123",
      password_confirmation: "password123"
    )

    get profile_path

    assert_response :success
    assert_select "h2", "Pending Invitations"
    assert_select "td", pending_invitation.email
    assert_select "td", pending_invitation.invitation_sent_at.to_date.iso8601
    assert_select "h2", "Accepted Invitations"
    assert_select "td", "Accepted Invite"
    assert_select "td", accepted_invitation.email
    assert_select "td", accepted_invitation.created_at.to_date.iso8601
  end
end
