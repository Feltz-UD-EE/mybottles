module CommunityCurated
  extend ActiveSupport::Concern

  STATUSES = [ "Pending", "Approved", "Rejected", "Merged" ].freeze
  STATUS_TAGS = {
    "Pending" => "Pending review",
    "Rejected" => "Rejected",
    "Merged" => "Merged"
  }.freeze

  included do
    belongs_to :created_by_user, class_name: "User", optional: true
    belongs_to :approved_by_user, class_name: "User", optional: true
    belongs_to :rejected_by_user, class_name: "User", optional: true
    belongs_to :merged_into, class_name: name, optional: true

    before_validation :assign_approval_defaults, on: :create

    validates :approval_status, inclusion: { in: STATUSES }

    scope :approved, -> { where(approval_status: "Approved") }
    scope :pending, -> { where(approval_status: "Pending") }
    scope :reviewable, -> { where(approval_status: [ "Pending", "Rejected", "Merged" ]) }
    scope :visible_to, ->(user) {
      if user&.reviewer?
        all
      elsif user
        where(approval_status: "Approved").or(where(created_by_user: user))
      else
        where(approval_status: "Approved")
      end
    }
  end

  def pending_review?
    approval_status == "Pending"
  end

  def approved?
    approval_status == "Approved"
  end

  def rejected?
    approval_status == "Rejected"
  end

  def merged?
    approval_status == "Merged"
  end

  def status_tag
    STATUS_TAGS[approval_status]
  end

  def review_target_name
    respond_to?(:display_name) ? display_name : to_s
  end

  def approve!(reviewer, attributes = {})
    update!(attributes.merge(
      approval_status: "Approved",
      approved_by_user: reviewer,
      approved_at: Time.current,
      rejected_by_user: nil,
      rejected_at: nil
    ))
  end

  def reject!(reviewer)
    update!(
      approval_status: "Rejected",
      rejected_by_user: reviewer,
      rejected_at: Time.current
    )
  end

  private

  def assign_approval_defaults
    self.created_by_user ||= Current.user || User.system_administrator

    if created_by_user&.reviewer?
      self.approval_status = "Approved"
      self.approved_by_user ||= created_by_user
      self.approved_at ||= Time.current
    else
      self.approval_status = "Pending"
    end
  end
end
