class Shelf < ApplicationRecord
  include OwnedByUser

  DEPTHS = %w[Single Multiple].freeze

  belongs_to :shelveable, polymorphic: true
  has_many :bottles, as: :cellarable, dependent: :restrict_with_error

  validates :depth, inclusion: { in: DEPTHS }
  validates :shelveable_type, inclusion: { in: %w[Cellar Bay] }

  def to_s
    display_name
  end

  def display_name
    location_name
  end

  def location_name
    if shelveable.is_a?(Bay)
      [ shelveable.cellar.name, [ shelveable.label, number ].compact_blank.join(" ") ].compact_blank.join(" - ")
    else
      [ shelveable.name, "Shelf #{number}".strip ].compact_blank.join(" - ")
    end
  end

  def cellarable_selection_name
    shelf_name = [ bay_selection_name, "Shelf #{number}".strip ].compact_blank.join(" ")

    [ shelf_name, label ].compact_blank.join(" - ")
  end

  def cellar
    shelveable.is_a?(Bay) ? shelveable.cellar : shelveable
  end

  def bay
    shelveable if shelveable.is_a?(Bay)
  end

  def current_bottle_count
    bottles.in_inventory.count
  end

  def shelveable_selection
    return if shelveable_type.blank? || shelveable_id.blank?

    "#{shelveable_type}:#{shelveable_id}"
  end

  private

  def bay_selection_name
    "Bay #{bay.label}".strip if bay
  end
end
