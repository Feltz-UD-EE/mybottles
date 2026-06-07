require "test_helper"

class WatchListEntryTest < ActiveSupport::TestCase
  test "requires description and supports soft delete and restore" do
    entry = WatchListEntry.new(description: "")

    assert_not entry.valid?
    assert_includes entry.errors[:description], "can't be blank"

    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    entry = WatchListEntry.create!(watchable: wine, description: "Find more.")

    assert_equal "Producer - Estate Red", entry.watchable_name
    assert_not entry.deleted?

    entry.soft_delete!

    assert entry.deleted?
    assert_includes WatchListEntry.deleted, entry
    assert_not_includes WatchListEntry.active, entry

    entry.restore!

    assert_not entry.deleted?
    assert_includes WatchListEntry.active, entry
  end
end
