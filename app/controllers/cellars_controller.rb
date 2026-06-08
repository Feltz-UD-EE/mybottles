class CellarsController < ApplicationController
  before_action :set_cellar, only: %i[ show edit update destroy ]

  def index
    @cellars = Cellar.order(:name)
  end

  def show
    @bins = @cellar.bins.order(:label)
    @bays = @cellar.bays.order(:label)
    @shelves = @cellar.shelves.order(:number)
  end

  def new
    @cellar = Cellar.new
  end

  def edit
  end

  def create
    @cellar = Cellar.new(cellar_params)

    if @cellar.save
      redirect_to @cellar, notice: "Cellar was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @cellar.update(cellar_params)
      redirect_to @cellar, notice: "Cellar was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @cellar.destroy
      redirect_to cellars_url, notice: "Cellar was successfully deleted."
    else
      redirect_to @cellar, alert: @cellar.errors.full_messages.to_sentence
    end
  end

  private

  def set_cellar
    @cellar = Cellar.find(params.expect(:id))
  end

  def cellar_params
    params.expect(cellar: %i[ name location notes ])
  end
end
