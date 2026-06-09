class ShelvesController < ApplicationController
  before_action :set_shelf, only: %i[ show edit update destroy ]
  before_action :load_shelveable_options, only: %i[ new edit create update ]

  def index
    @shelves = Shelf.visible_to(current_user).sort_by(&:location_name)
  end

  def show
  end

  def new
    @shelf = Shelf.new(params[:shelf]&.permit(:shelveable_type, :shelveable_id) || {})
    @shelf.depth ||= "Single"
  end

  def edit
  end

  def create
    attributes = shelf_params
    selection = attributes.delete(:shelveable_selection)
    @shelf = Shelf.new(attributes)

    if apply_shelveable_selection(@shelf, selection) && @shelf.save
      redirect_to @shelf, notice: "Shelf was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    attributes = shelf_params
    selection = attributes.delete(:shelveable_selection)
    valid_selection = apply_shelveable_selection(@shelf, selection)

    if valid_selection && @shelf.update(attributes)
      redirect_to @shelf, notice: "Shelf was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @shelf.destroy
      redirect_to shelves_url, notice: "Shelf was successfully deleted."
    else
      redirect_to @shelf, alert: @shelf.errors.full_messages.to_sentence
    end
  end

  private

  def set_shelf
    @shelf = Shelf.visible_to(current_user).find(params.expect(:id))
  end

  def shelf_params
    params.expect(shelf: %i[ shelveable_selection shelveable_type shelveable_id number label depth notes ])
  end

  def load_shelveable_options
    @shelveable_options = Cellar.visible_to(current_user).order(:name).map { |cellar| [ cellar.name, "Cellar:#{cellar.id}" ] } +
      Bay.visible_to(current_user).includes(:cellar).sort_by(&:display_name).map { |bay| [ bay.display_name, "Bay:#{bay.id}" ] }
  end

  def apply_shelveable_selection(shelf, selection)
    return true if selection.nil? && shelf.shelveable.present?

    type, id = selection.to_s.split(":", 2)
    unless %w[Cellar Bay].include?(type) && id.present?
      shelf.errors.add(:shelveable, "must be selected")
      return false
    end

    shelf.shelveable = type.constantize.find(id)
    true
  rescue ActiveRecord::RecordNotFound
    shelf.errors.add(:shelveable, "must be selected")
    false
  end
end
