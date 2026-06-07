class WatchListEntry < ApplicationRecord
  belongs_to :watchable, polymorphic: true, optional: true

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  validates :description, presence: true

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def restore!
    update!(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end

  def watchable_name
    watchable&.display_name.to_s
  end
end
