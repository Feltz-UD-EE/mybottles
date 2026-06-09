module UserReview
  class AllUsersController < ApplicationController
    before_action :authorize_system_administrator
    before_action :set_user, only: %i[ promote demote ]

    def index
      @users = User.order(:email)
    end

    def promote
      @user.promote!(current_user)
      redirect_to user_review_all_users_path, notice: "#{@user.email} was promoted."
    end

    def demote
      @user.demote!(current_user)
      redirect_to user_review_all_users_path, notice: "#{@user.email} was demoted."
    end

    private

    def authorize_system_administrator
      authorize :system_administrator, :index?
    end

    def set_user
      @user = User.find(params.expect(:id))
    end
  end
end
