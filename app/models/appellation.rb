# Appellations are displayed and routed as "Regions" throughout the UI.
class Appellation < ApplicationRecord
  belongs_to :country
  belongs_to :parent, class_name: "Appellation", optional: true
  has_many :children, class_name: "Appellation", foreign_key: :parent_id, dependent: :restrict_with_error, inverse_of: :parent
  has_many :appellation_grapes, dependent: :restrict_with_error
  has_many :grapes, through: :appellation_grapes

  accepts_nested_attributes_for :appellation_grapes, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true

  def to_s
    name
  end

  def display_name
    name
  end

  def path_name
    [ parent&.path_name, name ].compact_blank.join(" - ")
  end
end
