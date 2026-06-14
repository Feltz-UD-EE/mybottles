class TastingNote < ApplicationRecord
  include OwnedByUser

  BOOLEAN = ActiveModel::Type::Boolean.new

  attr_accessor :buy_yes, :buy_no

  belongs_to :tasteable, polymorphic: true

  before_validation :assign_buy_from_choices

  validates :date, presence: true
  validates :buy, inclusion: { in: [ true, false ] }, allow_nil: true
  validates :score, numericality: true, allow_nil: true
  validate :buy_choices_are_not_conflicting

  scope :for_bottles, ->(bottles) { where(tasteable_type: "Bottle", tasteable_id: bottles) }
  scope :for_vintages, ->(vintages) { where(tasteable_type: "Vintage", tasteable_id: vintages) }

  def self.for_vintage(vintage, user)
    bottle_ids = Bottle.visible_to(user).where(vintage: vintage).select(:id)
    visible_to(user)
      .where(tasteable_type: "Bottle", tasteable_id: bottle_ids)
      .or(visible_to(user).where(tasteable_type: "Vintage", tasteable_id: vintage.id))
      .includes(:tasteable)
      .order(date: :desc, created_at: :desc)
  end

  def self.for_wine(wine, user)
    vintage_ids = wine.vintages.visible_to(user).select(:id)
    bottle_ids = Bottle.visible_to(user).where(vintage_id: vintage_ids).select(:id)
    notes = visible_to(user)
      .where(tasteable_type: "Bottle", tasteable_id: bottle_ids)
      .or(visible_to(user).where(tasteable_type: "Vintage", tasteable_id: vintage_ids))
      .includes(:tasteable)

    sort_by_vintage_and_date_desc(notes)
  end

  def self.sort_by_vintage_and_date_desc(notes)
    notes.to_a.sort_by do |note|
      [
        note.vintage.vintage.to_s,
        note.date || Date.new(1, 1, 1),
        note.created_at || Time.zone.at(0)
      ]
    end.reverse
  end

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

  def attachment_name(context_bottle: nil)
    return "Vintage #{vintage.vintage}" if bottle.blank?
    return "This bottle (#{bottle.inventory_code})" if context_bottle == bottle

    "Bottle #{bottle.inventory_code}"
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
