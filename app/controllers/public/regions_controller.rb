module Public
  class RegionsController < BaseController
    def index
      @regions = Appellation.includes(:country).order("countries.name", "appellations.name")
    end

    def show
      @region = Appellation.find(params.expect(:id))
    end
  end
end
