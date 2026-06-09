module Public
  class WinesController < BaseController
    def index
      @wines = Wine.approved.includes(:producer).order("producers.name", "wines.name")
    end

    def show
      @wine = Wine.approved.includes(:producer).find(params.expect(:id))
      @vintages = @wine.vintages.approved.order(:vintage)
    end
  end
end
