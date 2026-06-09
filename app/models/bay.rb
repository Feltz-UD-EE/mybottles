class Bay < ApplicationRecord
  include OwnedByUser

  belongs_to :cellar
  has_many :shelves, as: :shelveable, dependent: :restrict_with_error

  def to_s
    display_name
  end

  def display_name
    [ cellar.name, label ].compact_blank.join(" - ")
  end

  def location_name
    display_name
  end

  def current_bottle_count
    Bottle.in_inventory.where(cellarable: shelves).count
  end
end
