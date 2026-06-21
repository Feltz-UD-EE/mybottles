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
    load_visible_wine_clubs
  end

  def new
    @producer = Producer.new
    load_producer_form_wines
  end

  def edit
    load_producer_form_wines
    load_visible_wine_clubs
  end

  def create
    @producer = Producer.new(producer_params)
    wine_attributes = producer_wine_params

    created_wines = save_producer_with_wines(@producer, wine_attributes)
    if created_wines
      redirect_to @producer, notice: producer_save_notice("created", created_wines.count)
    else
      load_producer_form_wines(wine_attributes)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    wine_attributes = producer_wine_params
    created_wines = update_producer_with_wines(@producer, producer_params, wine_attributes)

    if created_wines
      redirect_to @producer, notice: producer_save_notice("updated", created_wines.count)
    else
      load_producer_form_wines(wine_attributes)
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
    params.expect(producer: %i[ name address email website phone notes tasting_room club_options ])
  end

  def producer_wine_params
    params.fetch(:producer, {})
      .fetch(:wines_attributes, {})
      .permit!
      .to_h
      .values
      .map { |attributes| attributes.stringify_keys.slice("name", "description", "style", "color", "appellation", "vintage") }
      .reject { |attributes| attributes.values.all?(&:blank?) }
  end

  def load_producer_form_wines(submitted_wines = nil)
    @existing_wines = @producer.persisted? ? @producer.wines.visible_to(current_user).order(:name) : Wine.none
    @producer_wines = submitted_wines.presence || [ {} ]
  end

  def load_visible_wine_clubs
    @wine_clubs = @producer.wine_clubs.visible_to(current_user).order(:date_left, :tier, :created_at)
  end

  def save_producer_with_wines(producer, wine_attributes)
    created_wines = []

    ActiveRecord::Base.transaction do
      producer.save!
      created_wines = create_wines_for_producer!(producer, wine_attributes)
    end

    created_wines
  rescue ActiveRecord::RecordInvalid => error
    merge_nested_errors(@producer, error.record)
    false
  end

  def update_producer_with_wines(producer, producer_attributes, wine_attributes)
    created_wines = []

    ActiveRecord::Base.transaction do
      unless handle_community_update(producer, producer_attributes)
        raise ActiveRecord::Rollback
      end

      created_wines = create_wines_for_producer!(producer, wine_attributes)
    end

    created_wines
  rescue ActiveRecord::RecordInvalid => error
    merge_nested_errors(@producer, error.record)
    false
  end

  def create_wines_for_producer!(producer, wine_attributes)
    wine_attributes.map do |attributes|
      vintage_value = attributes["vintage"]
      wine = producer.wines.create!(attributes.except("vintage").merge(created_by_user: current_user))
      wine.vintages.create!(vintage: vintage_value, created_by_user: current_user) if vintage_value.present?
      wine
    end
  end

  def merge_nested_errors(producer, record)
    return if record == producer

    record.errors.full_messages.each { |message| producer.errors.add(:base, message) }
  end

  def producer_save_notice(action, wine_count)
    "Producer was successfully #{action}. #{wine_count} #{'wine'.pluralize(wine_count)} #{wine_count == 1 ? 'was' : 'were'} created."
  end
end
