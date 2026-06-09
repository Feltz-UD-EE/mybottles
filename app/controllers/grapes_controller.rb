class GrapesController < ApplicationController
  include CommunityCuratedController

  before_action :set_grape, only: %i[ show edit update destroy ]

  def index
    @grapes = visible_scope(Grape).order(:name)
  end

  def show
    @pending_changes = ProposedChange.pending.for_target(@grape).where(proposed_by_user: current_user)
    @synonym_relationships = @grape.synonym_relationships.includes(:grape, :synonym_grape).order(:created_at)
    @allowed_appellations = @grape.allowed_appellations_with_source.sort_by { |appellation, _source, _notes| appellation.path_name }
    @grape_synonym = GrapeSynonym.new(grape: @grape)
    @grape_options = Grape.visible_to(current_user).where.not(id: @grape.id).order(:name)
  end

  def new
    @grape = Grape.new
  end

  def edit
  end

  def create
    @grape = Grape.new(grape_params)

    if @grape.save
      redirect_to @grape, notice: "Grape was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if handle_community_update(@grape, grape_params)
      redirect_to @grape, notice: community_update_notice(@grape)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @grape.destroy
      redirect_to grapes_url, notice: "Grape was successfully deleted."
    else
      redirect_to @grape, alert: @grape.errors.full_messages.to_sentence
    end
  end

  private

  def set_grape
    @grape = visible_scope(Grape).find(params.expect(:id))
  end

  def grape_params
    params.expect(grape: %i[ name notes ])
  end
end
