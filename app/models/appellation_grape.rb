class AppellationGrape < ApplicationRecord
  include CommunityCurated

  belongs_to :appellation
  belongs_to :grape

  validates :appellation, :grape, presence: true
  validates :grape_id, uniqueness: {
    scope: :appellation_id,
    conditions: -> { where.not(approval_status: "Merged") },
    message: "is already allowed for this appellation"
  }

  def to_s
    display_name
  end

  def display_name
    [ appellation.path_name, grape.name ].join(" - ")
  end
end
