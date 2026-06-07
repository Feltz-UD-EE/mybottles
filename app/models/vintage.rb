class Vintage < ApplicationRecord
  belongs_to :wine
  has_many :bottles, dependent: :restrict_with_error
  has_many :tasting_notes, as: :tasteable, dependent: :restrict_with_error

  validates :vintage, presence: true

  def to_s
    "#{wine} #{vintage}"
  end

  def display_name
    [ wine.display_name, vintage ].compact_blank.join(" - ")
  end
end
