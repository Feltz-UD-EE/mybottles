class ProposedChange < ApplicationRecord
  include PublicActivity::Model

  STATUSES = [ "Pending", "Approved", "Rejected", "Superseded", "Merged", "Needs More Info" ].freeze
  ACTIONS = [ "Update", "Merge" ].freeze

  tracked owner: proc { |_controller, model| model.proposed_by_user }

  belongs_to :target, polymorphic: true
  belongs_to :proposed_by_user, class_name: "User"
  belongs_to :reviewed_by_user, class_name: "User", optional: true
  belongs_to :duplicate_of, polymorphic: true, optional: true

  validates :status, inclusion: { in: STATUSES }
  validates :action, inclusion: { in: ACTIONS }
  validates :submitted_at, presence: true
  validates :proposed_attributes, :original_attributes, presence: true

  before_validation :assign_defaults, on: :create

  scope :pending, -> { where(status: "Pending") }
  scope :for_target, ->(target) { where(target: target) }

  def approve!(reviewer, reviewer_attributes: nil)
    attrs = (reviewer_attributes.presence || proposed_attributes).to_h

    transaction do
      target.update!(attrs)
      update!(
        status: "Approved",
        reviewed_by_user: reviewer,
        reviewed_at: Time.current,
        reviewer_attributes: attrs
      )
      create_activity key: "proposed_change.approved", owner: reviewer
    end
  end

  def reject!(reviewer, notes = nil)
    update!(
      status: "Rejected",
      reviewed_by_user: reviewer,
      reviewed_at: Time.current,
      review_notes: notes
    )
    create_activity key: "proposed_change.rejected", owner: reviewer
  end

  def supersede!(reviewer, notes = nil)
    update!(
      status: "Superseded",
      reviewed_by_user: reviewer,
      reviewed_at: Time.current,
      review_notes: notes
    )
  end

  def drifted?
    original_attributes.any? { |name, value| target.public_send(name).to_s != value.to_s }
  end

  def changed_fields
    proposed_attributes.keys.join(", ")
  end

  private

  def assign_defaults
    self.status ||= "Pending"
    self.action ||= "Update"
    self.submitted_at ||= Time.current
    self.proposed_attributes ||= {}
    self.original_attributes ||= {}
  end
end
