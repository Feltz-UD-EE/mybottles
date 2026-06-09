class Grape < ApplicationRecord
  include CommunityCurated

  has_many :grape_synonyms, dependent: :destroy
  has_many :inverse_grape_synonyms, class_name: "GrapeSynonym", foreign_key: :synonym_grape_id, dependent: :destroy
  has_many :appellation_grapes, dependent: :restrict_with_error
  has_many :appellations, through: :appellation_grapes

  validates :name, presence: true

  def to_s
    name
  end

  def display_name
    name
  end

  def selection_name
    [ name, notes.presence&.truncate(80) ].compact.join(" - ")
  end

  def synonym_relationships
    GrapeSynonym.visible_to(Current.user).where(grape: self).or(GrapeSynonym.visible_to(Current.user).where(synonym_grape: self))
  end

  def synonym_grapes
    synonym_relationships.includes(:grape, :synonym_grape).map { |relationship| relationship.other_grape(self) }.uniq
  end

  def related_grapes
    [ self, *synonym_grapes ].uniq
  end

  def allowed_appellation_rows
    AppellationGrape.visible_to(Current.user).includes(:appellation, :grape).where(grape: related_grapes)
  end

  def allowed_appellations_with_source
    direct_ids = AppellationGrape.visible_to(Current.user).where(grape: self).pluck(:appellation_id)

    allowed_appellation_rows.map do |row|
      source = direct_ids.include?(row.appellation_id) ? "Direct" : "Via #{row.grape.name}"
      [ row.appellation, source, row.notes ]
    end.uniq { |appellation, _source, _notes| appellation.id }
  end
end
