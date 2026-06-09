class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_paper_trail_whodunnit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :reviewer?, :system_administrator?, :pending_promotion_event

  private

  def set_current_user
    Current.user = current_user
  end

  def user_for_paper_trail
    current_user&.id
  end

  def reviewer?
    current_user&.reviewer?
  end

  def system_administrator?
    current_user&.system_administrator?
  end

  def pending_promotion_event
    return unless current_user

    @pending_promotion_event ||= UserTrustEvent.promotions.undismissed_for(current_user).order(created_at: :desc).first
  end

  def user_not_authorized
    redirect_back_or_to root_path, alert: "You are not authorized to do that."
  end
end
