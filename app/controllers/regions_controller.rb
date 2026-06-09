# Regions are Appellation records exposed with friendlier route and UI language.
class RegionsController < ApplicationController
  before_action :set_region, only: %i[ show edit update destroy ]
  before_action :load_form_options, only: %i[ new edit create update ]
  before_action :authorize_system_administrator, except: %i[ index show ]

  def index
    @country = Country.find(params[:country_id]) if params[:country_id].present?
    @regions = Appellation.includes(:country, :parent)
    @regions = @regions.where(country: @country) if @country
    @regions = @regions.sort_by { |region| [ region.country.name, region.path_name ] }
  end

  def show
    @child_regions = @region.children.order(:name)
    @appellation_grapes = @region.appellation_grapes.visible_to(current_user).includes(:grape).order("grapes.name")
  end

  def new
    @region = Appellation.new(region_defaults)
    @region.appellation_grapes.build
  end

  def edit
    @region.appellation_grapes.build if @region.appellation_grapes.empty?
  end

  def create
    @region = Appellation.new(region_params)

    if @region.save
      redirect_to region_path(@region), notice: "Region was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @region.update(region_params)
      redirect_to region_path(@region), notice: "Region was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @region.destroy
      redirect_to regions_url, notice: "Region was successfully deleted."
    else
      redirect_to region_path(@region), alert: @region.errors.full_messages.to_sentence
    end
  end

  private

  def set_region
    @region = Appellation.find(params.expect(:id))
  end

  def region_params
    params.require(:appellation).permit(
      :country_id,
      :name,
      :degree,
      :parent_id,
      :notes,
      :auto_generated,
      appellation_grapes_attributes: %i[ id grape_id notes _destroy ]
    )
  end

  def region_defaults
    defaults = params.fetch(:appellation, {}).permit(:country_id, :parent_id)
    defaults[:country_id] = params[:country_id] if defaults[:country_id].blank? && params[:country_id].present?
    defaults
  end

  def load_form_options
    @countries = Country.order(:name)
    @parent_regions = Appellation.includes(:country).order(:name)
    @parent_regions = @parent_regions.where.not(id: @region.id) if defined?(@region) && @region&.persisted?
    @grapes = Grape.visible_to(current_user).order(:name)
  end

  def authorize_system_administrator
    authorize :system_administrator, :update?
  end
end
