class BinsController < ApplicationController
  before_action :set_bin, only: %i[ show edit update destroy ]

  def index
    @bins = Bin.includes(:cellar).order("cellars.name", "bins.label")
  end

  def show
  end

  def new
    @bin = Bin.new(params[:bin]&.permit(:cellar_id) || {})
  end

  def edit
  end

  def create
    @bin = Bin.new(bin_params)

    if @bin.save
      redirect_to @bin, notice: "Bin was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @bin.update(bin_params)
      redirect_to @bin, notice: "Bin was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @bin.destroy
      redirect_to bins_url, notice: "Bin was successfully deleted."
    else
      redirect_to @bin, alert: @bin.errors.full_messages.to_sentence
    end
  end

  private

  def set_bin
    @bin = Bin.find(params.expect(:id))
  end

  def bin_params
    params.expect(bin: %i[ cellar_id label location notes ])
  end
end
