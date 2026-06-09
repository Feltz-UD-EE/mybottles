class CountriesController < ApplicationController
  before_action :set_country, only: %i[ show edit update destroy ]
  before_action :authorize_system_administrator, except: %i[ index show ]

  def index
    @countries = Country.order(:name)
  end

  def show
    @root_regions = @country.appellations.includes(:children).where(parent_id: nil).order(:name)
  end

  def new
    @country = Country.new
  end

  def edit
  end

  def create
    @country = Country.new(country_params)

    if @country.save
      redirect_to @country, notice: "Country was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @country.update(country_params)
      redirect_to @country, notice: "Country was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @country.destroy
      redirect_to countries_url, notice: "Country was successfully deleted."
    else
      redirect_to @country, alert: @country.errors.full_messages.to_sentence
    end
  end

  private

  def set_country
    @country = Country.find(params.expect(:id))
  end

  def country_params
    params.expect(country: %i[ name fullname iso2 iso3 notes ])
  end

  def authorize_system_administrator
    authorize :system_administrator, :update?
  end
end
