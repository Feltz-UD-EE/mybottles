module Review
  class DashboardController < ApplicationController
    before_action :authorize_reviewer

    def index
      @pending_records = [ Producer, Wine, Vintage ].flat_map { |model| model.pending.includes(:created_by_user).to_a }
      @proposed_changes = ProposedChange.pending.includes(:target, :proposed_by_user).order(:submitted_at)
    end

    private

    def authorize_reviewer
      authorize :reviewer, :index?
    end
  end
end
