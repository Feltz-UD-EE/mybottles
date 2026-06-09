class WineClub < ApplicationRecord
  include OwnedByUser

  DELIVERY_METHODS = %w[Shipping Pickup].freeze

  belongs_to :producer

  validates :size, presence: true, numericality: { only_integer: true }
  validates :schedule, presence: true
  validates :delivery_method, inclusion: { in: DELIVERY_METHODS }, allow_blank: true
  validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :current, -> { where(date_left: nil) }

  def current_member?
    date_left.nil?
  end

  def display_name
    [ producer.name, tier.presence ].compact.join(" - ")
  end
end
