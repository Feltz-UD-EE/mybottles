class WinesController < ApplicationController
  include CommunityCuratedController

  before_action :set_wine, only: %i[ show edit update destroy ]

  def index
    @wines = visible_scope(Wine).includes(:producer).order("producers.name", "wines.name")
    @tasted_wine_ids = tasted_wine_ids(@wines)
  end

  def show
    @pending_changes = ProposedChange.pending.for_target(@wine).where(proposed_by_user: current_user)
    @vintages = @wine.vintages.visible_to(current_user).includes(:bottles).order(:vintage)
    @tasting_notes = @wine.tasting_notes_for_wine(current_user)
    @average_rating = @wine.average_rating(current_user)
  end

  def new
    @wine = Wine.new({ style: "Still" }.merge(params[:wine]&.permit(:producer_id, :style) || {}))
  end

  def edit
  end

  def create
    @wine = Wine.new(wine_params)

    if @wine.save
      redirect_to @wine, notice: "Wine was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if handle_community_update(@wine, wine_params)
      redirect_to @wine, notice: community_update_notice(@wine)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @wine.destroy
      redirect_to wines_url, notice: "Wine was successfully deleted."
    else
      redirect_to @wine, alert: @wine.errors.full_messages.to_sentence
    end
  end

  private

  def set_wine
    @wine = visible_scope(Wine).find(params.expect(:id))
  end

  def wine_params
    params.expect(wine: %i[ name description producer_id style color appellation ])
  end

  def tasted_wine_ids(wines)
    wine_ids = wines.select(:id)
    vintage_ids = Vintage.visible_to(current_user).where(wine_id: wine_ids).select(:id)
    directly_tasted_vintage_ids = TastingNote
      .visible_to(current_user)
      .where(tasteable_type: "Vintage", tasteable_id: vintage_ids)
      .select(:tasteable_id)
    direct_ids = Vintage.visible_to(current_user)
      .where(id: directly_tasted_vintage_ids)
      .distinct
      .pluck(:wine_id)
    bottle_ids = Bottle.visible_to(current_user).where(vintage_id: vintage_ids).select(:id)
    directly_tasted_bottle_ids = TastingNote
      .visible_to(current_user)
      .where(tasteable_type: "Bottle", tasteable_id: bottle_ids)
      .select(:tasteable_id)
    via_bottle_ids = Bottle.visible_to(current_user)
      .joins(:vintage)
      .where(id: directly_tasted_bottle_ids)
      .distinct
      .pluck("vintages.wine_id")

    (direct_ids + via_bottle_ids).to_set
  end
end
