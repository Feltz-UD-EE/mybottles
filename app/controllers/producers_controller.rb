class ProducersController < ApplicationController
  include CommunityCuratedController

  before_action :set_producer, only: %i[ show edit update destroy ]

  def index
    @producers = visible_scope(Producer).order(:name)
    @producer_inventory_counts = Bottle
      .joins(vintage: :wine)
      .where(disposal_date: nil)
      .group("wines.producer_id")
      .count
  end

  def show
    @pending_changes = ProposedChange.pending.for_target(@producer).where(proposed_by_user: current_user)
    @wines = @producer.wines.visible_to(current_user).order(:name)
  end

  def new
    @producer = Producer.new
  end

  def edit
  end

  def create
    @producer = Producer.new(producer_params)

    if @producer.save
      redirect_to @producer, notice: "Producer was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if handle_community_update(@producer, producer_params)
      redirect_to @producer, notice: community_update_notice(@producer)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @producer.destroy
      redirect_to producers_url, notice: "Producer was successfully deleted."
    else
      redirect_to @producer, alert: @producer.errors.full_messages.to_sentence
    end
  end

  private

  def set_producer
    @producer = visible_scope(Producer).find(params.expect(:id))
  end

  def producer_params
    params.expect(producer: %i[ name address email website phone ])
  end
end
