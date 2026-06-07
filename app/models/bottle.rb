class Bottle < ApplicationRecord
  DISPOSAL_METHODS = %w[Drink Gift Sale Spoiled].freeze

  belongs_to :vintage

  before_validation :normalize_blank_disposal_method

  validates :list_price, :discount_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :disposal_method, inclusion: { in: DISPOSAL_METHODS }, allow_blank: true
  validate :disposal_date_must_not_be_before_purchase_date

  def in_inventory?
    disposal_date.nil?
  end

  def to_s
    [ personal_inventory, vintage.to_s ].compact_blank.join(" - ")
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
