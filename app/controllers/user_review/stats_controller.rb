module UserReview
  class StatsController < ApplicationController
    before_action :authorize_reviewer

    def index
      build_stats
      render :show
    end

    def show
      build_stats
    end

    private

    def authorize_reviewer
      authorize :reviewer, :index?
    end

    def build_stats
      @counts = User.group(:trust_level).count
      @basic_users_created_90_days = User.basic.where("created_at >= ?", 90.days.ago).count
      @promotions_90_days = UserTrustEvent.promotions.where("created_at >= ?", 90.days.ago).group(:to_trust_level).count
    end
  end
end
