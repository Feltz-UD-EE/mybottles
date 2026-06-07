class Wine < ApplicationRecord
  STYLES = %w[Still Sparkling Fortified Flavored].freeze
  COLORS = [ "Red", "White", "Rosé", "Orange" ].freeze

  belongs_to :producer
  has_many :vintages, dependent: :restrict_with_error
  has_many :bottles, through: :vintages
  has_many :bottles_in_inventory, -> { where(disposal_date: nil) }, through: :vintages, source: :bottles

  validates :name, presence: true
  validates :style, inclusion: { in: STYLES }, allow_blank: true
  validates :color, inclusion: { in: COLORS }, allow_blank: true
  validate :producer_id_cannot_change, on: :update

  def to_s
    name
  end

  def display_name
    [ producer.name, name ].compact_blank.join(" - ")
  end

  private

  def producer_id_cannot_change
    return unless will_save_change_to_producer_id?

    errors.add(:producer_id, "cannot be changed")
  end
end
