class Bottle < ApplicationRecord
  include OwnedByUser

  attr_accessor :quantity

  DISPOSAL_METHODS = [ "Drink", "Gift", "Sale", "Spoiled", "Inventory Adjustment" ].freeze
  AUTO_INVENTORY_FORMAT = /\A[A-Z0-9]+\z/

  belongs_to :vintage
  belongs_to :cellarable, polymorphic: true, optional: true
  has_many :tasting_notes, as: :tasteable, dependent: :restrict_with_error

  before_validation :normalize_blank_disposal_method
  before_validation :assign_auto_inventory

  scope :in_inventory, -> { where(disposal_date: nil) }
  scope :disposed, -> { where.not(disposal_date: nil) }
  scope :uncellared, -> { where(cellarable_type: nil, cellarable_id: nil) }

  validates :list_price, :discount_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :disposal_method, inclusion: { in: DISPOSAL_METHODS }, allow_blank: true
  validates :cellarable_type, inclusion: { in: %w[Cellar Bin Shelf] }, allow_blank: true
  validates :auto_inventory, format: { with: AUTO_INVENTORY_FORMAT }, allow_blank: true
  validates :auto_inventory, uniqueness: { scope: :user_id }, allow_blank: true
  validate :disposal_date_must_not_be_before_purchase_date

  def in_inventory?
    disposal_date.nil?
  end

  def to_s
    [ inventory_code, vintage.to_s ].compact_blank.join(" - ")
  end

  def display_name
    vintage.display_name
  end

  def inventory_display_name
    [ inventory_code, display_name ].compact_blank.join(" - ")
  end

  def tasting_notes_for_same_vintage
    TastingNote.for_vintage(vintage, user)
  end

  def tasted?
    tasting_notes.exists?
  end

  def inventory_code
    personal_inventory.presence || auto_inventory_display
  end

  def auto_inventory_display
    return if auto_inventory.blank?

    code = auto_inventory.rjust(6, "0")
    "#{code.first(3)}-#{code.last(3)}"
  end

  def location_name
    cellarable&.location_name || "Not Cellared"
  end

  def on_hand_display
    in_inventory? ? location_name : "No"
  end

  def cellarable_selection
    return if cellarable_type.blank? || cellarable_id.blank?

    "#{cellarable_type}:#{cellarable_id}"
  end

  private

  def normalize_blank_disposal_method
    self.disposal_method = nil if disposal_method.blank?
  end

  def assign_auto_inventory
    return if personal_inventory.present? || auto_inventory.present? || user.blank?

    user.with_lock do
      loop do
        code = auto_inventory_code(user.next_auto_inventory_number)
        user.next_auto_inventory_number += 1
        user.save!

        unless self.class.where(user: user, auto_inventory: code).where.not(id: id).exists?
          self.auto_inventory = code
          break
        end
      end
    end
  end

  def auto_inventory_code(number)
    number.to_i.to_s(36).upcase.rjust(6, "0")
  end

  def disposal_date_must_not_be_before_purchase_date
    return if purchase_date.blank? || disposal_date.blank?
    return if disposal_date >= purchase_date

    errors.add(:disposal_date, "must be on or after purchase date")
  end
end
