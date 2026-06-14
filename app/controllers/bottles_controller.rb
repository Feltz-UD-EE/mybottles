class BottlesController < ApplicationController
  before_action :set_bottle, only: %i[ show label edit update destroy ]
  before_action :load_cellarable_options, only: %i[ new edit create update ]

  def index
    @bottles = Bottle.visible_to(current_user).includes(vintage: { wine: :producer }).order(purchase_date: :desc, created_at: :desc)
    @tasted_bottle_ids = tasted_bottle_ids(@bottles)
  end

  def show
    @vintage = @bottle.vintage
    @wine = @vintage.wine
    @producer = @wine.producer
    @tasting_notes = @bottle.tasting_notes_for_same_vintage
  end

  def label
    @vintage = @bottle.vintage
    @wine = @vintage.wine
    @producer = @wine.producer
    @label_app_name = Rails.configuration.x.label_printing.app_name
    @label_url = bottle_label_url(@bottle)
    @qr_svg = RQRCode::QRCode.new(@label_url, size: 4, level: :l).as_svg(
      color: "000",
      fill: "fff",
      module_size: 4,
      shape_rendering: "crispEdges",
      standalone: true,
      viewbox: true,
      use_path: true
    )
  end

  def new
    @bottle = Bottle.new(params[:bottle]&.permit(:vintage_id) || {})
  end

  def edit
  end

  def create
    attributes = bottle_params
    selection = attributes.delete(:cellarable_selection)
    @bottle = Bottle.new(attributes)

    if apply_cellarable_selection(@bottle, selection) && @bottle.save
      redirect_to bottle_url(@bottle, print_label: current_user.print_labels_by_default?), notice: "Bottle was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    attributes = bottle_params
    selection = attributes.delete(:cellarable_selection)
    valid_selection = apply_cellarable_selection(@bottle, selection)

    if valid_selection && @bottle.update(attributes)
      redirect_to @bottle, notice: "Bottle was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @bottle.destroy
      redirect_to bottles_url, notice: "Bottle was successfully deleted."
    else
      redirect_to @bottle, alert: @bottle.errors.full_messages.to_sentence
    end
  end

  private

  def set_bottle
    @bottle = Bottle.visible_to(current_user).find(params.expect(:id))
  end

  def bottle_label_url(bottle)
    URI.join(Rails.configuration.x.label_printing.base_url, bottle_path(bottle)).to_s
  end

  def bottle_params
    params.expect(bottle: %i[ personal_inventory vintage_id purchase_date purchase_source list_price discount_price notes disposal_date disposal_method cellarable_selection ])
  end

  def tasted_bottle_ids(bottles)
    TastingNote
      .visible_to(current_user)
      .where(tasteable_type: "Bottle", tasteable_id: bottles.select(:id))
      .distinct
      .pluck(:tasteable_id)
      .to_set
  end

  def load_cellarable_options
    @cellarable_options = [ [ "Not Cellared", "" ] ] +
      Cellar.visible_to(current_user).order(:name).map { |cellar| [ cellar.name, "Cellar:#{cellar.id}" ] } +
      Bin.visible_to(current_user).includes(:cellar).sort_by(&:display_name).map { |bin| [ bin.display_name, "Bin:#{bin.id}" ] } +
      Shelf.visible_to(current_user).sort_by(&:location_name).map { |shelf| [ shelf.location_name, "Shelf:#{shelf.id}" ] }
  end

  def apply_cellarable_selection(bottle, selection)
    return true if selection.nil?

    if selection.blank?
      bottle.cellarable = nil
      return true
    end

    type, id = selection.split(":", 2)
    unless %w[Cellar Bin Shelf].include?(type) && id.present?
      bottle.errors.add(:cellarable, "is invalid")
      return false
    end

    bottle.cellarable = type.constantize.find(id)
    true
  rescue ActiveRecord::RecordNotFound
    bottle.errors.add(:cellarable, "is invalid")
    false
  end
end
