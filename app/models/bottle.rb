class Bottle < ApplicationRecord
  DISPOSAL_METHODS = %w[Drink Gift Sale Spoiled].freeze

  belongs_to :vintage
  belongs_to :cellarable, polymorphic: true, optional: true
  has_many :tasting_notes, as: :tasteable, dependent: :restrict_with_error

  before_validation :normalize_blank_disposal_method

  scope :in_inventory, -> { where(disposal_date: nil) }

  validates :list_price, :discount_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :disposal_method, inclusion: { in: DISPOSAL_METHODS }, allow_blank: true
  validates :cellarable_type, inclusion: { in: %w[Cellar Bin Shelf] }, allow_blank: true
  validate :disposal_date_must_not_be_before_purchase_date

  def in_inventory?
    disposal_date.nil?
  end

  def to_s
    [ personal_inventory, vintage.to_s ].compact_blank.join(" - ")
  end

  def display_name
    vintage.display_name
  end

  def inventory_display_name
    [ personal_inventory, display_name ].compact_blank.join(" - ")
  end

  def location_name
    cellarable&.location_name || "Not Cellared"
  end

  def cellarable_selection
    return if cellarable_type.blank? || cellarable_id.blank?

    "#{cellarable_type}:#{cellarable_id}"
  end

  private

  def normalize_blank_disposal_method
    self.disposal_method = nil if disposal_method.blank?
  end

  def disposal_date_must_not_be_before_purchase_date
    return if purchase_date.blank? || disposal_date.blank?
    return if disposal_date >= purchase_date

    errors.add(:disposal_date, "must be on or after purchase date")
  end
end
