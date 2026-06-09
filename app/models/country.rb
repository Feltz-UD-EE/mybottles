class Country < ApplicationRecord
  has_many :appellations, dependent: :restrict_with_error

  validates :name, :iso2, :iso3, presence: true

  def to_s
    name
  end

  def named_region_count
    appellations.count
  end
end
