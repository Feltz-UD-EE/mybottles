module Review
  class CommunityRecordsController < ApplicationController
    before_action :authorize_reviewer
    before_action :set_model
    before_action :set_record, only: %i[ show approve reject merge ]

    def index
      @records = @model.reviewable.includes(:created_by_user).order(:created_at)
    end

    def show
      @canonical_options = @model.approved.where.not(id: @record.id).order(:created_at)
    end

    def approve
      @record.approve!(current_user)
      redirect_to review_root_path, notice: "#{@model.model_name.human} was approved."
    end

    def reject
      @record.reject!(current_user)
      redirect_to review_root_path, notice: "#{@model.model_name.human} was rejected."
    end

    def merge
      canonical = @model.approved.find(params.expect(:canonical_id))
      merge_record!(@record, canonical)
      redirect_to review_root_path, notice: "#{@model.model_name.human} was merged."
    end

    private

    def authorize_reviewer
      authorize :reviewer, :index?
    end

    def set_model
      @model = params[:type].constantize
      raise ActiveRecord::RecordNotFound unless [ Producer, Wine, Vintage, Grape, GrapeSynonym, AppellationGrape ].include?(@model)
    end

    def set_record
      @record = @model.find(params.expect(:id))
    end

    def merge_record!(record, canonical)
      record.transaction do
        case record
        when Producer
          Wine.where(producer: record).update_all(producer_id: canonical.id)
        when Wine
          Vintage.where(wine: record).update_all(wine_id: canonical.id)
        when Vintage
          Bottle.where(vintage: record).update_all(vintage_id: canonical.id)
          TastingNote.where(tasteable: record).update_all(tasteable_id: canonical.id)
          WatchListEntry.where(watchable: record).update_all(watchable_id: canonical.id)
        when Grape
          GrapeSynonym.where(grape: record).update_all(grape_id: canonical.id)
          GrapeSynonym.where(synonym_grape: record).update_all(synonym_grape_id: canonical.id)
          AppellationGrape.where(grape: record).update_all(grape_id: canonical.id)
        end

        record.update!(
          approval_status: "Merged",
          merged_into: canonical,
          approved_by_user: current_user,
          approved_at: Time.current
        )
      end
    end
  end
end
