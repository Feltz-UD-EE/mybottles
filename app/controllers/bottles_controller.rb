class BottlesController < ApplicationController
  before_action :set_bottle, only: %i[ show edit update destroy ]

  def index
    @bottles = Bottle.includes(vintage: { wine: :producer }).order(created_at: :desc)
  end

  def show
    @vintage = @bottle.vintage
    @wine = @vintage.wine
    @producer = @wine.producer
  end

  def new
    @bottle = Bottle.new
  end

  def edit
  end

  def create
    @bottle = Bottle.new(bottle_params)

    if @bottle.save
      redirect_to @bottle, notice: "Bottle was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @bottle.update(bottle_params)
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
    @bottle = Bottle.find(params.expect(:id))
  end

  def bottle_params
    params.expect(bottle: %i[ personal_inventory vintage_id purchase_date purchase_source list_price discount_price notes disposal_date disposal_method ])
  end
end
