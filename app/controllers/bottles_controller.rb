class BottlesController < ApplicationController
  before_action :set_bottle, only: %i[ show label edit update destroy ]
  before_action :load_cellarable_options, only: %i[ new edit create update ]

  def index
    @bottles = Bottle.visible_to(current_user).in_inventory.includes(vintage: { wine: :producer }).order(purchase_date: :desc, created_at: :desc)
    @tasted_bottle_ids = tasted_bottle_ids(@bottles)
  end

  def uncellared
    @bottles = Bottle.visible_to(current_user).in_inventory.uncellared.includes(vintage: { wine: :producer }).order(purchase_date: :desc, created_at: :desc)
  end

  def adjust_uncellared_inventory
    bottle_ids = params.fetch(:bottle_ids, []).compact_blank
    adjusted_count = Bottle
      .visible_to(current_user)
      .in_inventory
      .uncellared
      .where(id: bottle_ids)
      .update_all(disposal_method: "Inventory Adjustment", disposal_date: Date.current, updated_at: Time.current)

    redirect_to uncellared_bottles_url, notice: "#{adjusted_count} #{'bottle'.pluralize(adjusted_count)} adjusted."
  end

  def disposed
    @disposal_method = params[:disposal_method].presence
    @bottles = Bottle.visible_to(current_user).disposed.includes(vintage: { wine: :producer }).order(disposal_date: :desc, created_at: :desc)
    @bottles = @bottles.where(disposal_method: @disposal_method) if Bottle::DISPOSAL_METHODS.include?(@disposal_method)
    @tasted_bottle_ids = tasted_bottle_ids(@bottles)
  end

  def show
    @vintage = @bottle.vintage
    @wine = @vintage.wine
    @producer = @wine.producer
    @tasting_notes = @bottle.tasting_notes_for_same_vintage
    @same_wine_bottles = same_wine_bottles
    @print_label_url = safe_print_label_url(params[:print_label_url]) || label_bottle_path(@bottle)
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

  def labels
    ids = params[:ids].to_s.split(",").filter_map { |id| id.presence }
    @bottles = Bottle.visible_to(current_user).where(id: ids).includes(vintage: { wine: :producer }).to_a
    @bottles = ids.filter_map { |id| @bottles.find { |bottle| bottle.id == id } }
    @label_app_name = Rails.configuration.x.label_printing.app_name
  end

  def new
    @bottle = Bottle.new(params[:bottle]&.permit(:vintage_id) || {})
    @bottle.quantity = 1
  end

  def edit
  end

  def create
    attributes = bottle_params
    quantity = extract_quantity(attributes)
    selection = attributes.delete(:cellarable_selection)

    unless quantity
      @bottle.quantity = params.dig(:bottle, :quantity)
      apply_cellarable_selection(@bottle, selection)
      render :new, status: :unprocessable_entity
      return
    end

    created_bottles = create_bottles(attributes, selection, quantity)
    first_bottle = created_bottles.first

    redirect_to bottle_url(first_bottle, print_label_params(created_bottles, attributes[:personal_inventory])), notice: bottle_create_notice(created_bottles.count, attributes[:personal_inventory])
  rescue ActiveRecord::RecordInvalid => error
    @bottle = error.record
    @bottle.quantity = quantity || params.dig(:bottle, :quantity)
    render :new, status: :unprocessable_entity
  rescue ActiveRecord::Rollback
    @bottle.quantity = quantity || params.dig(:bottle, :quantity)
    render :new, status: :unprocessable_entity
  end

  def update
    attributes = bottle_params
    selection = attributes.delete(:cellarable_selection)
    valid_selection = apply_cellarable_selection(@bottle, selection)

    if valid_selection && @bottle.update(attributes)
      redirect_to bottles_url, notice: "#{@bottle.display_name} was successfully updated."
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

  def extract_quantity(attributes)
    raw_quantity = (attributes.delete(:quantity).presence || "1").to_s.strip
    quantity = Integer(raw_quantity, exception: false)

    return quantity if quantity&.positive? && raw_quantity.match?(/\A\d+\z/)

    @bottle = Bottle.new(attributes)
    @bottle.errors.add(:quantity, "must be an integer greater than or equal to 1")
    nil
  end

  def create_bottles(attributes, selection, quantity)
    created_bottles = []

    ActiveRecord::Base.transaction do
      quantity.times do |index|
        bottle_attributes = attributes.dup
        bottle_attributes[:personal_inventory] = nil if index.positive? && attributes[:personal_inventory].present?
        bottle = Bottle.new(bottle_attributes)

        unless apply_cellarable_selection(bottle, selection)
          @bottle = bottle
          raise ActiveRecord::Rollback
        end

        bottle.save!
        created_bottles << bottle
      end
    end

    raise ActiveRecord::Rollback if created_bottles.empty?

    created_bottles
  end

  def print_label_params(created_bottles, personal_inventory)
    return { print_label: false } unless current_user.print_labels_by_default?
    return { print_label: true } if personal_inventory.present? || created_bottles.one?

    { print_label: true, print_label_url: labels_bottles_path(ids: created_bottles.map(&:id).join(",")) }
  end

  def bottle_create_notice(count, personal_inventory)
    return "Bottle was successfully created." if count == 1
    return "#{count} bottles were successfully created." if personal_inventory.blank?

    "#{count} bottles were successfully created. Only the first bottle has the personal inventory code. The remaining #{count - 1} bottles do not have their personal inventory code completed; do not print labels for those bottles until after updating their personal inventory code."
  end

  def set_bottle
    @bottle = Bottle.visible_to(current_user).find(params.expect(:id))
  end

  def safe_print_label_url(url)
    return if url.blank?
    return if url.start_with?("//")

    url if url.start_with?("/")
  end

  def bottle_label_url(bottle)
    URI.join(Rails.configuration.x.label_printing.base_url, bottle_path(bottle)).to_s
  end

  def same_wine_bottles
    Bottle
      .visible_to(current_user)
      .in_inventory
      .joins(:vintage)
      .where(vintages: { wine_id: @wine.id })
      .where.not(id: @bottle.id)
      .includes(:cellarable, vintage: { wine: :producer })
      .order("vintages.vintage", :personal_inventory, :auto_inventory)
  end

  def bottle_params
    params.expect(bottle: %i[ personal_inventory vintage_id purchase_date purchase_source list_price discount_price notes disposal_date disposal_method cellarable_selection quantity ])
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
      Bin.visible_to(current_user).includes(:cellar).sort_by(&:display_name).map { |bin| [ bin.cellarable_selection_name, "Bin:#{bin.id}" ] } +
      Shelf.visible_to(current_user).includes(:shelveable).sort_by(&:location_name).map { |shelf| [ shelf.cellarable_selection_name, "Shelf:#{shelf.id}" ] }
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
