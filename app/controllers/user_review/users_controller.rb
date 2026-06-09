module UserReview
  class UsersController < ApplicationController
    before_action :authorize_reviewer
    before_action :set_user, only: %i[ show promote demote ]

    def index
      @trust_level = params[:trust_level]
      @users = User.where(trust_level: @trust_level).order(:email)
      @metrics = @users.index_with { |user| UserContributionMetrics.new(user) }
    end

    def show
      @metrics = UserContributionMetrics.new(@user)
      @suggested_edits = @metrics.suggested_edits.includes(:target, :reviewed_by_user).order(submitted_at: :desc)
      @new_entries = @metrics.new_entry_records.sort_by(&:created_at).reverse
    end

    def promote
      authorize_promotion!
      @user.promote!(current_user)
      redirect_back_or_to user_review_user_path(@user), notice: "#{@user.email} was promoted."
    end

    def demote
      authorize_all_users_admin!
      @user.demote!(current_user)
      redirect_back_or_to user_review_user_path(@user), notice: "#{@user.email} was demoted."
    end

    private

    def authorize_reviewer
      authorize :reviewer, :index?
    end

    def set_user
      @user = User.find(params.expect(:id))
    end

    def authorize_promotion!
      if @user.trusted?
        authorize :system_administrator, :update?
      else
        authorize :reviewer, :update?
      end
    end

    def authorize_all_users_admin!
      authorize :system_administrator, :update?
    end
  end
end
