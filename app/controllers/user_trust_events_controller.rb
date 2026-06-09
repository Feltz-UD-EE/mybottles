class UserTrustEventsController < ApplicationController
  def dismiss
    event = current_user.user_trust_events.find(params.expect(:id))
    event.update!(dismissed_at: Time.current)
    redirect_back_or_to dashboard_path, notice: "Message dismissed."
  end
end
