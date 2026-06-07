require "test_helper"

class WatchListEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @producer = Producer.create!(name: "Producer")
    @wine = Wine.create!(name: "Estate Red", producer: @producer)
    @vintage = Vintage.create!(vintage: "2024", wine: @wine)
  end

  test "lists active watch list entries with dynamic table UI" do
    active_entry = WatchListEntry.create!(watchable: @wine, description: "Find more.")
    WatchListEntry.create!(watchable: @vintage, description: "Old.", deleted_at: Time.current)

    get watch_list_entries_url

    assert_response :success
    assert_select "h1", "Watch List"
    assert_select "[data-controller='table']"
    assert_select "td", "Find more."
    assert_select "td", text: "Old.", count: 0
    assert_select "form[action=?]", remove_watch_list_entry_path(active_entry), text: "Remove"
    assert_select ".watch-list-history p", "1 previous watch list item"
    assert_select "a[href=?]", old_entries_watch_list_entries_path, "Old Items"
  end

  test "lists old entries and restores" do
    entry = WatchListEntry.create!(watchable: @vintage, description: "Find this again.", deleted_at: Time.current)

    get old_entries_watch_list_entries_url

    assert_response :success
    assert_select "h1", "Old Watch List Entries"
    assert_select "td", "Find this again."
    assert_select "form[action=?]", restore_watch_list_entry_path(entry), text: "Restore"

    patch restore_watch_list_entry_url(entry)

    assert_redirected_to old_entries_watch_list_entries_url
    assert_nil entry.reload.deleted_at
  end

  test "new preloads wine watchable and creates entry" do
    get new_watch_list_entry_url(watch_list_entry: { watchable_type: "Wine", watchable_id: @wine.id })

    assert_response :success
    assert_select "h2", "Wine"
    assert_select "input[name='watch_list_entry[watchable_id]'][value=?]", @wine.id

    assert_difference("WatchListEntry.count", 1) do
      post watch_list_entries_url, params: {
        watch_list_entry: {
          watchable_type: "Wine",
          watchable_id: @wine.id,
          description: "Buy at next release.",
          quantity: "2 bottles"
        }
      }
    end

    entry = WatchListEntry.order(:created_at).last
    assert_redirected_to watch_list_entry_url(entry)
    assert_equal @wine, entry.watchable
  end

  test "creates free text entry and soft deletes instead of destroying" do
    assert_difference("WatchListEntry.count", 1) do
      post watch_list_entries_url, params: {
        watch_list_entry: {
          description: "Find a dinner wine.",
          notes: "Look locally."
        }
      }
    end

    entry = WatchListEntry.order(:created_at).last
    assert_nil entry.watchable

    assert_no_difference("WatchListEntry.count") do
      patch remove_watch_list_entry_url(entry)
    end

    assert_redirected_to watch_list_entries_url
    assert entry.reload.deleted?
  end
end
