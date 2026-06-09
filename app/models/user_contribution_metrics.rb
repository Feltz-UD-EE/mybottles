class UserContributionMetrics
  COMMUNITY_MODELS = [ Producer, Wine, Vintage, Grape, GrapeSynonym, AppellationGrape ].freeze

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def days_since_account_creation
    return 0 unless user.created_at

    ((Time.current - user.created_at) / 1.day).floor
  end

  def suggested_edits_count
    suggested_edits.count
  end

  def suggested_edits_approved_count
    suggested_edits.where(status: "Approved").count
  end

  def suggested_edits_rejected_count
    suggested_edits.where(status: "Rejected").count
  end

  def new_entries_count
    new_entries.sum(&:count)
  end

  def new_entries_approved_count
    new_entries_with_status("Approved")
  end

  def new_entries_rejected_count
    new_entries_with_status("Rejected")
  end

  def suggested_edits_count_90_days
    suggested_edits_since_90_days.count
  end

  def suggested_edits_approved_90_days
    suggested_edits_since_90_days.where(status: "Approved").count
  end

  def suggested_edits_rejected_90_days
    suggested_edits_since_90_days.where(status: "Rejected").count
  end

  def new_entries_count_90_days
    new_entries_since_90_days.sum(&:count)
  end

  def new_entries_approved_90_days
    new_entries_since_90_days.sum { |scope| scope.where(approval_status: "Approved").count }
  end

  def new_entries_rejected_90_days
    new_entries_since_90_days.sum { |scope| scope.where(approval_status: "Rejected").count }
  end

  def suggested_edits
    ProposedChange.where(proposed_by_user: user)
  end

  def new_entry_records
    COMMUNITY_MODELS.flat_map { |model| model.where(created_by_user: user).to_a }
  end

  def metric_hash
    {
      days_since_account_creation: days_since_account_creation,
      suggested_edits_count: suggested_edits_count,
      suggested_edits_approved_count: suggested_edits_approved_count,
      suggested_edits_rejected_count: suggested_edits_rejected_count,
      new_entries_count: new_entries_count,
      new_entries_approved_count: new_entries_approved_count,
      new_entries_rejected_count: new_entries_rejected_count,
      suggested_edits_count_90_days: suggested_edits_count_90_days,
      suggested_edits_approved_90_days: suggested_edits_approved_90_days,
      suggested_edits_rejected_90_days: suggested_edits_rejected_90_days,
      new_entries_count_90_days: new_entries_count_90_days,
      new_entries_approved_90_days: new_entries_approved_90_days,
      new_entries_rejected_90_days: new_entries_rejected_90_days
    }
  end

  private

  def cutoff
    90.days.ago
  end

  def suggested_edits_since_90_days
    suggested_edits.where("submitted_at >= ?", cutoff)
  end

  def new_entries
    COMMUNITY_MODELS.map { |model| model.where(created_by_user: user) }
  end

  def new_entries_since_90_days
    new_entries.map { |scope| scope.where("created_at >= ?", cutoff) }
  end

  def new_entries_with_status(status)
    new_entries.sum { |scope| scope.where(approval_status: status).count }
  end
end
