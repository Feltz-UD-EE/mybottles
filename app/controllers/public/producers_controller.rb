module Public
  class ProducersController < BaseController
    def index
      @producers = Producer.approved.order(:name)
    end

    def show
      @producer = Producer.approved.find(params.expect(:id))
      @wines = @producer.wines.approved.order(:name)
    end
  end
end
