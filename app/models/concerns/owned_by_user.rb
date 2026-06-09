module OwnedByUser
  extend ActiveSupport::Concern

  included do
    belongs_to :user

    before_validation :assign_default_user

    scope :owned_by, ->(user) { where(user: user) }
    scope :visible_to, ->(user) {
      if user&.system_administrator?
        all
      else
        where(user: user)
      end
    }
  end

  private

  def assign_default_user
    self.user ||= Current.user || User.system_administrator
  end
end
