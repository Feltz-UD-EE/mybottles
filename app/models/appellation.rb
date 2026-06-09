# Appellations are displayed and routed as "Regions" throughout the UI.
class Appellation < ApplicationRecord
  belongs_to :country
  belongs_to :parent, class_name: "Appellation", optional: true
  has_many :children, class_name: "Appellation", foreign_key: :parent_id, dependent: :restrict_with_error, inverse_of: :parent

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
