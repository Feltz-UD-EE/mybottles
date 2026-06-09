class Cellar < ApplicationRecord
  include OwnedByUser

  has_many :bins, dependent: :restrict_with_error
  has_many :bays, dependent: :restrict_with_error
  has_many :shelves, as: :shelveable, dependent: :restrict_with_error
  has_many :bottles, as: :cellarable, dependent: :restrict_with_error

  validates :name, presence: true

  def to_s
    name
  end

  def display_name
    name
  end

  def location_name
    name
  end

  def current_bottle_count
    direct_bottles.in_inventory.count +
      Bin.joins(:bottles).merge(bins).merge(Bottle.in_inventory).count +
      Shelf.joins(:bottles).merge(all_shelves).merge(Bottle.in_inventory).count
  end

  def direct_bottles
    bottles
  end

  def all_shelves
    Shelf.where(shelveable: self).or(Shelf.where(shelveable: bays))
  end
end
