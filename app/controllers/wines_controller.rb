class WinesController < ApplicationController
  before_action :set_wine, only: %i[ show edit update destroy ]

  def index
    @wines = Wine.includes(:producer).order("producers.name", "wines.name")
  end

  def show
    @vintages = @wine.vintages.includes(:bottles).order(:vintage)
  end

  def new
    @wine = Wine.new
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
    if @wine.update(wine_params)
      redirect_to @wine, notice: "Wine was successfully updated."
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
    @wine = Wine.find(params.expect(:id))
  end

  def wine_params
    params.expect(wine: %i[ name description producer_id style color appellation ])
  end
end
