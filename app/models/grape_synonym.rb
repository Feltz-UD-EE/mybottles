class GrapeSynonym < ApplicationRecord
  include CommunityCurated

  belongs_to :grape
  belongs_to :synonym_grape, class_name: "Grape"

  validates :grape, :synonym_grape, presence: true
  validate :grapes_must_be_different
  validate :unordered_pair_must_be_unique

  def to_s
    display_name
  end

  def display_name
    [ grape.name, synonym_grape.name ].join(" / ")
  end

  def other_grape(source)
    source == grape ? synonym_grape : grape
  end

  private

  def grapes_must_be_different
    return if grape_id.blank? || synonym_grape_id.blank? || grape_id != synonym_grape_id

    errors.add(:synonym_grape_id, "must be different from grape")
  end

  def unordered_pair_must_be_unique
    return if grape_id.blank? || synonym_grape_id.blank?

    low, high = [ grape_id, synonym_grape_id ].sort
    duplicate = self.class
      .where.not(id: id)
      .where("LEAST(grape_id, synonym_grape_id) = ? AND GREATEST(grape_id, synonym_grape_id) = ?", low, high)
      .where.not(approval_status: "Merged")
      .exists?
    errors.add(:synonym_grape_id, "already has this synonym relationship") if duplicate
  end
end
