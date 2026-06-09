class GrapeSynonymsController < ApplicationController
  include CommunityCuratedController

  before_action :set_grape_synonym, only: %i[ edit update destroy ]

  def create
    @grape_synonym = GrapeSynonym.new(grape_synonym_params)

    if @grape_synonym.save
      redirect_to @grape_synonym.grape, notice: "Grape synonym was successfully created."
    else
      redirect_to @grape_synonym.grape || grapes_path, alert: @grape_synonym.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if handle_community_update(@grape_synonym, grape_synonym_params)
      redirect_to @grape_synonym.grape, notice: community_update_notice(@grape_synonym)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    grape = @grape_synonym.grape

    if @grape_synonym.destroy
      redirect_to grape, notice: "Grape synonym was successfully deleted."
    else
      redirect_to grape, alert: @grape_synonym.errors.full_messages.to_sentence
    end
  end

  private

  def set_grape_synonym
    @grape_synonym = visible_scope(GrapeSynonym).find(params.expect(:id))
  end

  def grape_synonym_params
    params.expect(grape_synonym: %i[ grape_id synonym_grape_id notes ])
  end
end
