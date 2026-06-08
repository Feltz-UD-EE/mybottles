class TastingNote < ApplicationRecord
  BOOLEAN = ActiveModel::Type::Boolean.new

  attr_accessor :buy_yes, :buy_no

  belongs_to :tasteable, polymorphic: true

  before_validation :assign_buy_from_choices

  validates :date, presence: true
  validates :buy, inclusion: { in: [ true, false ] }, allow_nil: true
  validates :score, numericality: true, allow_nil: true
  validate :buy_choices_are_not_conflicting

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

  def buy_yes_selected?
    return buy == true if buy_yes.nil?

    BOOLEAN.cast(buy_yes)
  end

  def buy_no_selected?
    return buy == false if buy_no.nil?

    BOOLEAN.cast(buy_no)
  end

  private

  def assign_buy_from_choices
    return if buy_yes.nil? && buy_no.nil?
    return if buy_yes_selected? && buy_no_selected?

    self.buy =
      if buy_yes_selected?
        true
      elsif buy_no_selected?
        false
      end
  end

  def buy_choices_are_not_conflicting
    return unless buy_yes_selected? && buy_no_selected?

    errors.add(:buy, "cannot be both Yes and No")
  end
end
