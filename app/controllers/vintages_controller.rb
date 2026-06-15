class VintagesController < ApplicationController
  include CommunityCuratedController

  before_action :set_vintage, only: %i[ show edit update destroy ]

  def index
    @vintages = visible_scope(Vintage).includes(wine: :producer).order("producers.name", "wines.name", "vintages.vintage")
    @tasted_vintage_ids = tasted_vintage_ids(@vintages)
  end

  def show
    @pending_changes = ProposedChange.pending.for_target(@vintage).where(proposed_by_user: current_user)
    @bottles = @vintage.bottles.visible_to(current_user).order(:purchase_date, :personal_inventory, :auto_inventory)
    @tasting_notes = @vintage.tasting_notes_for_wine(current_user)
    @average_rating = @vintage.average_rating(current_user)
  end

  def new
    @vintage = Vintage.new(params[:vintage]&.permit(:wine_id) || {})
  end

  def edit
  end

  def create
    @vintage = Vintage.new(vintage_params)

    if @vintage.save
      redirect_to @vintage, notice: "Vintage was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if handle_community_update(@vintage, vintage_params)
      redirect_to @vintage, notice: community_update_notice(@vintage)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @vintage.destroy
      redirect_to vintages_url, notice: "Vintage was successfully deleted."
    else
      redirect_to @vintage, alert: @vintage.errors.full_messages.to_sentence
    end
  end

  private

  def set_vintage
    @vintage = visible_scope(Vintage).find(params.expect(:id))
  end

  def vintage_params
    params.expect(vintage: %i[ vintage wine_id grapes ])
  end

  def tasted_vintage_ids(vintages)
    vintage_ids = vintages.select(:id)
    direct_ids = TastingNote
      .visible_to(current_user)
      .where(tasteable_type: "Vintage", tasteable_id: vintage_ids)
      .distinct
      .pluck(:tasteable_id)
    bottle_ids = Bottle.visible_to(current_user).where(vintage_id: vintage_ids).select(:id)
    tasted_bottle_ids = TastingNote
      .visible_to(current_user)
      .where(tasteable_type: "Bottle", tasteable_id: bottle_ids)
      .select(:tasteable_id)
    via_bottle_ids = Bottle.visible_to(current_user)
      .where(id: tasted_bottle_ids)
      .distinct
      .pluck(:vintage_id)

    (direct_ids + via_bottle_ids).to_set
  end
end
