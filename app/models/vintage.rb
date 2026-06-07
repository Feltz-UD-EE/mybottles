class Vintage < ApplicationRecord
  belongs_to :wine
  has_many :bottles, dependent: :restrict_with_error

  validates :vintage, presence: true

  def to_s
    "#{wine} #{vintage}"
  end
end
