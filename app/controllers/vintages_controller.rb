class VintagesController < ApplicationController
  before_action :set_vintage, only: %i[ show edit update destroy ]

  def index
    @vintages = Vintage.includes(wine: :producer).order("producers.name", "wines.name", "vintages.vintage")
  end

  def show
    @bottles = @vintage.bottles.order(:purchase_date, :personal_inventory)
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
    if @vintage.update(vintage_params)
      redirect_to @vintage, notice: "Vintage was successfully updated."
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
    @vintage = Vintage.find(params.expect(:id))
  end

  def vintage_params
    params.expect(vintage: %i[ vintage wine_id grapes ])
  end
end
