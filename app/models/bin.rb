class Bin < ApplicationRecord
  include OwnedByUser

  belongs_to :cellar
  has_many :bottles, as: :cellarable, dependent: :restrict_with_error

  def to_s
    display_name
  end

  def display_name
    [ cellar.name, label ].compact_blank.join(" - ")
  end

  def location_name
    display_name
  end

  def cellarable_selection_name
    [ "Bin #{location}".strip, label ].compact_blank.join(" - ")
  end

  def current_bottle_count
    bottles.in_inventory.count
  end

  def current_bottles
    bottles.in_inventory
  end
end
