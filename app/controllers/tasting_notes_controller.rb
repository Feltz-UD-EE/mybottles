class TastingNotesController < ApplicationController
  before_action :set_tasting_note, only: %i[ show edit update destroy ]
  before_action :load_vintage_options, only: %i[ new edit create update ]

  def index
    @tasting_notes = TastingNote.includes(:tasteable).order(date: :desc)
  end

  def show
  end

  def new
    @tasting_note = TastingNote.new(
      date: params[:date].presence || Date.current,
      setting: params[:setting]
    )
    assign_tasteable_from_params
  end

  def edit
  end

  def create
    @tasting_note = TastingNote.new(tasting_note_params)
    assign_tasteable_from_params

    if @tasting_note.save
      update_tasted_bottle
      add_watch_list_entry
      redirect_after_create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_tasteable_from_params

    if @tasting_note.update(tasting_note_params)
      update_tasted_bottle
      redirect_to @tasting_note, notice: "Tasting note was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tasting_note.destroy
    redirect_to tasting_notes_url, notice: "Tasting note was successfully deleted."
  end

  private

  def set_tasting_note
    @tasting_note = TastingNote.find(params.expect(:id))
  end

  def tasting_note_params
    params.expect(tasting_note: %i[ date setting temperature pairing color nose palate overall score buy buy_yes buy_no ])
  end

  def tasteable_params
    params.fetch(:tasting_note, {}).permit(:tasteable_type, :tasteable_id, :vintage_lookup)
  end

  def new_wine_params
    params.fetch(:new_wine, {}).permit(:producer_name, :wine_name, :vintage, :appellation, :grapes)
  end

  def assign_tasteable_from_params
    explicit_type = tasteable_params[:tasteable_type]
    explicit_id = tasteable_params[:tasteable_id]

    @tasting_note.tasteable =
      if explicit_type == "Bottle" && explicit_id.present?
        Bottle.find(explicit_id)
      elsif explicit_type == "Vintage" && explicit_id.present?
        Vintage.find(explicit_id)
      elsif new_wine_params[:producer_name].present? || new_wine_params[:wine_name].present? || new_wine_params[:vintage].present?
        find_or_create_inline_vintage
      else
        @tasting_note.tasteable
      end

    return if @tasting_note.tasteable.present?
    return unless action_name.in?(%w[create update])

    @tasting_note.errors.add(:tasteable, "must be selected")
  end

  def find_or_create_inline_vintage
    values = new_wine_params

    if values[:producer_name].blank? || values[:wine_name].blank? || values[:vintage].blank?
      @tasting_note.errors.add(:tasteable, "requires producer, wine, and vintage")
      return nil
    end

    Producer.transaction do
      producer = Producer.find_or_create_by!(name: values[:producer_name].strip)
      wine = Wine.find_or_initialize_by(producer: producer, name: values[:wine_name].strip)
      wine.appellation = values[:appellation].presence
      wine.save!

      vintage = Vintage.find_or_initialize_by(wine: wine, vintage: values[:vintage].strip)
      vintage.grapes = values[:grapes].presence
      vintage.save!
      vintage
    end
  end

  def update_tasted_bottle
    return unless @tasting_note.tasteable.is_a?(Bottle)

    @tasting_note.tasteable.update!(
      disposal_date: @tasting_note.date,
      disposal_method: "Drink"
    )
  end

  def add_watch_list_entry
    return unless @tasting_note.buy == true

    vintage = @tasting_note.vintage
    WatchListEntry.active.find_or_create_by!(watchable: vintage) do |entry|
      entry.description = "Buy again based on tasting note from #{@tasting_note.date.iso8601}"
      entry.notes = @tasting_note.overall
    end
  end

  def redirect_after_create
    if params[:finish_action] == "taste_another"
      redirect_to new_tasting_note_path(date: @tasting_note.date, setting: @tasting_note.setting), notice: "Tasting note was successfully created."
    else
      redirect_to root_path, notice: "Tasting note was successfully created."
    end
  end

  def load_vintage_options
    @vintage_options = Vintage.includes(wine: :producer).order("producers.name", "wines.name", "vintages.vintage")
  end
end
