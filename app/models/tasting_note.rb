class TastingNote < ApplicationRecord
  belongs_to :tasteable, polymorphic: true

  validates :date, presence: true
  validates :buy, inclusion: { in: [ true, false ] }, allow_nil: true
  validates :score, numericality: true, allow_nil: true

  def producer
    wine.producer
  end

  def wine
    vintage.wine
  end

  def vintage
    tasteable.is_a?(Bottle) ? tasteable.vintage : tasteable
  end

  def bottle
    tasteable if tasteable.is_a?(Bottle)
  end

  def tasteable_name
    tasteable.display_name
  end

  def buy_label
    return "" if buy.nil?

    buy? ? "Yes" : "No"
  end
end
