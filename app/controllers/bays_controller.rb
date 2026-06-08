class BaysController < ApplicationController
  before_action :set_bay, only: %i[ show edit update destroy ]

  def index
    @bays = Bay.includes(:cellar).order("cellars.name", "bays.label")
  end

  def show
    @shelves = @bay.shelves.order(:number)
  end

  def new
    @bay = Bay.new(params[:bay]&.permit(:cellar_id) || {})
  end

  def edit
  end

  def create
    @bay = Bay.new(bay_params)

    if @bay.save
      redirect_to @bay, notice: "Bay was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @bay.update(bay_params)
      redirect_to @bay, notice: "Bay was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @bay.destroy
      redirect_to bays_url, notice: "Bay was successfully deleted."
    else
      redirect_to @bay, alert: @bay.errors.full_messages.to_sentence
    end
  end

  private

  def set_bay
    @bay = Bay.find(params.expect(:id))
  end

  def bay_params
    params.expect(bay: %i[ cellar_id label location notes ])
  end
end
