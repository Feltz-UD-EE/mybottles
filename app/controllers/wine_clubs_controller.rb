class WineClubsController < ApplicationController
  before_action :set_wine_club, only: %i[ show edit update destroy ]
  before_action :load_producers, only: %i[ new edit create update ]

  def index
    @wine_clubs = WineClub.visible_to(current_user).current.includes(:producer).order("producers.name", "wine_clubs.tier")
  end

  def all
    @wine_clubs = WineClub.visible_to(current_user).includes(:producer).order("producers.name", "wine_clubs.tier")
  end

  def show
  end

  def new
    @wine_club = WineClub.new
  end

  def edit
  end

  def create
    @wine_club = WineClub.new(wine_club_params)
    if assign_inline_producer && @wine_club.save
      redirect_to @wine_club, notice: "Wine club was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if assign_inline_producer && @wine_club.update(wine_club_params)
      redirect_to @wine_club, notice: "Wine club was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @wine_club.destroy
      redirect_to wine_clubs_url, notice: "Wine club was successfully deleted."
    else
      redirect_to @wine_club, alert: @wine_club.errors.full_messages.to_sentence
    end
  end

  private

  def set_wine_club
    @wine_club = WineClub.visible_to(current_user).find(params.expect(:id))
  end

  def wine_club_params
    params.expect(wine_club: %i[
      producer_id
      tier
      size
      schedule
      delivery_method
      payment_method
      discount
      date_joined
      date_left
      member_id
      benefits
    ])
  end

  def new_producer_params
    params.fetch(:new_producer, {}).permit(:name, :address, :email, :website, :phone)
  end

  def assign_inline_producer
    values = new_producer_params
    return true if values.values.all?(&:blank?)

    producer = Producer.new(values)
    if producer.save
      @wine_club.producer = producer
      true
    else
      producer.errors.full_messages.each { |message| @wine_club.errors.add(:producer, message) }
      false
    end
  end

  def load_producers
    @producers = Producer.visible_to(current_user).order(:name)
  end
end
