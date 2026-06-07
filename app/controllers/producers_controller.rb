class ProducersController < ApplicationController
  before_action :set_producer, only: %i[ show edit update destroy ]

  def index
    @producers = Producer.order(:name)
    @producer_inventory_counts = Bottle
      .joins(vintage: :wine)
      .where(disposal_date: nil)
      .group("wines.producer_id")
      .count
  end

  def show
    @wines = @producer.wines.order(:name)
  end

  def new
    @producer = Producer.new
  end

  def edit
  end

  def create
    @producer = Producer.new(producer_params)

    if @producer.save
      redirect_to @producer, notice: "Producer was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @producer.update(producer_params)
      redirect_to @producer, notice: "Producer was successfully updated."
    else
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
    @producer = Producer.find(params.expect(:id))
  end

  def producer_params
    params.expect(producer: %i[ name address email website phone ])
  end
end
