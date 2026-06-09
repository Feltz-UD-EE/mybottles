module Review
  class ProposedChangesController < ApplicationController
    before_action :authorize_reviewer
    before_action :set_proposed_change

    def show
      @related_changes = ProposedChange.pending.for_target(@proposed_change.target).where.not(id: @proposed_change.id)
    end

    def approve
      @proposed_change.approve!(current_user, reviewer_attributes: reviewer_attributes)
      redirect_to review_root_path, notice: "Proposed change was approved."
    end

    def reject
      @proposed_change.reject!(current_user, params[:review_notes])
      redirect_to review_root_path, notice: "Proposed change was rejected."
    end

    def supersede
      @proposed_change.supersede!(current_user, params[:review_notes])
      redirect_to review_root_path, notice: "Proposed change was superseded."
    end

    private

    def authorize_reviewer
      authorize :reviewer, :index?
    end

    def set_proposed_change
      @proposed_change = ProposedChange.find(params.expect(:id))
    end

    def reviewer_attributes
      params.fetch(:reviewer_attributes, {}).permit!.to_h.presence
    end
  end
end
