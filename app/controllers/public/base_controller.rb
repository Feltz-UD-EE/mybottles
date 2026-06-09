module Public
  class BaseController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :set_current_user
    skip_before_action :set_paper_trail_whodunnit
  end
end
