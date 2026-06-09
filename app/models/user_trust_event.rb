class UserTrustEvent < ApplicationRecord
  ACTIONS = [ "Promotion", "Demotion" ].freeze

  belongs_to :user
  belongs_to :actor, class_name: "User"

  validates :from_trust_level, :to_trust_level, inclusion: { in: User::TRUST_LEVELS }
  validates :action, inclusion: { in: ACTIONS }

  scope :promotions, -> { where(action: "Promotion") }
  scope :undismissed_for, ->(user) { where(user: user, dismissed_at: nil) }

  def promotion?
    action == "Promotion"
  end
end
