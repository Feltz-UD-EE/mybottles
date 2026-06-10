class InvitationsController < ApplicationController
  before_action :authorize_reviewer

  def new
    @user = User.new(trust_level: "Basic")
  end

  def create
    @user = User.invite!(invite_params, current_user)

    if @user.errors.empty?
      redirect_to dashboard_path, notice: "Invitation was sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def authorize_reviewer
    authorize :reviewer, :create?
  end

  def invite_params
    params.expect(user: %i[ email trust_level name ])
  end
end
