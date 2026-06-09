class AppellationGrapesController < ApplicationController
  include CommunityCuratedController

  before_action :set_appellation_grape, only: %i[ edit update destroy ]

  def edit
  end

  def update
    if handle_community_update(@appellation_grape, appellation_grape_params)
      redirect_to region_path(@appellation_grape.appellation), notice: community_update_notice(@appellation_grape)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    appellation = @appellation_grape.appellation

    if @appellation_grape.destroy
      redirect_to region_path(appellation), notice: "Appellation grape was successfully deleted."
    else
      redirect_to region_path(appellation), alert: @appellation_grape.errors.full_messages.to_sentence
    end
  end

  private

  def set_appellation_grape
    @appellation_grape = visible_scope(AppellationGrape).find(params.expect(:id))
  end

  def appellation_grape_params
    params.expect(appellation_grape: %i[ appellation_id grape_id notes ])
  end
end
