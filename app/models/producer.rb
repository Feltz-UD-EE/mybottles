class Producer < ApplicationRecord
  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
  HTTP_URL_FORMAT = /\Ahttps?:\/\/\S+\z/

  has_many :wines, dependent: :restrict_with_error
  has_many :wine_clubs, dependent: :restrict_with_error
  has_many :vintages, through: :wines
  has_many :bottles, through: :vintages
  has_many :bottles_in_inventory, -> { where(disposal_date: nil) }, through: :vintages, source: :bottles

  validates :name, presence: true
  validates :email, format: { with: EMAIL_FORMAT }, allow_blank: true
  validates :website, format: { with: HTTP_URL_FORMAT }, allow_blank: true

  def bottles_in_inventory_count
    bottles_in_inventory.count
  end

  def to_s
    name
  end
end
