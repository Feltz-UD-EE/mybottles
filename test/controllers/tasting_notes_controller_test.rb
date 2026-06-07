require "test_helper"

class TastingNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @producer = Producer.create!(name: "Producer")
    @wine = Wine.create!(name: "Estate Red", producer: @producer)
    @vintage = Vintage.create!(vintage: "2024", wine: @wine)
    @bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage)
  end

  test "lists tasting notes with dynamic table UI" do
    TastingNote.create!(date: Date.new(2026, 6, 7), tasteable: @vintage, overall: "Lovely.")

    get tasting_notes_url

    assert_response :success
    assert_select "h1", "Tasting Notes"
    assert_select "[data-controller='table']"
    assert_select "td", "Lovely."
  end

  test "new from bottle preloads bottle and creates note that marks bottle as drunk" do
    get new_tasting_note_url(tasting_note: { tasteable_type: "Bottle", tasteable_id: @bottle.id })

    assert_response :success
    assert_select "h2", "Bottle"
    assert_select "input[name='tasting_note[tasteable_id]'][value=?]", @bottle.id

    assert_difference("TastingNote.count", 1) do
      post tasting_notes_url, params: {
        tasting_note: {
          tasteable_type: "Bottle",
          tasteable_id: @bottle.id,
          date: "2026-06-07",
          setting: "Home",
          overall: "Very nice.",
          buy: "1"
        },
        finish_action: "done"
      }
    end

    assert_redirected_to root_url
    assert_equal Date.new(2026, 6, 7), @bottle.reload.disposal_date
    assert_equal "Drink", @bottle.disposal_method
  end

  test "new tasting note renders vintage picker without validation errors" do
    get new_tasting_note_url

    assert_response :success
    assert_select ".error-messages", count: 0
    assert_select "input[name='tasting_note[vintage_lookup]']"
    assert_select "[data-tasting-note-target='newWineFields'][hidden]"
  end

  test "creates tasting note for existing vintage and taste another preserves date and setting" do
    assert_difference("TastingNote.count", 1) do
      post tasting_notes_url, params: {
        tasting_note: {
          tasteable_type: "Vintage",
          tasteable_id: @vintage.id,
          date: "2026-06-07",
          setting: "Tasting room",
          overall: "Good.",
          buy: "0"
        },
        finish_action: "taste_another"
      }
    end

    assert_redirected_to new_tasting_note_url(date: "2026-06-07", setting: "Tasting room")
  end

  test "creates producer wine vintage and tasting note inline" do
    assert_difference("Producer.count", 1) do
      assert_difference("Wine.count", 1) do
        assert_difference("Vintage.count", 1) do
          assert_difference("TastingNote.count", 1) do
            post tasting_notes_url, params: {
              tasting_note: {
                date: "2026-06-07",
                setting: "Retailer",
                overall: "Buy again.",
                buy: "1"
              },
              new_wine: {
                producer_name: "New Producer",
                wine_name: "New Wine",
                vintage: "NV",
                appellation: "Michigan",
                grapes: "Riesling"
              },
              finish_action: "done"
            }
          end
        end
      end
    end

    note = TastingNote.order(:created_at).last
    assert_redirected_to root_url
    assert_equal "New Producer - New Wine - NV", note.tasteable_name
  end

  test "updates and deletes tasting note" do
    note = TastingNote.create!(date: Date.new(2026, 6, 7), tasteable: @vintage, overall: "Good.")

    patch tasting_note_url(note), params: {
      tasting_note: {
        tasteable_type: "Vintage",
        tasteable_id: @vintage.id,
        date: "2026-06-08",
        overall: "Excellent.",
        buy: "1"
      }
    }

    assert_redirected_to tasting_note_url(note)
    assert_equal Date.new(2026, 6, 8), note.reload.date
    assert_equal "Excellent.", note.overall
    assert note.buy?

    assert_difference("TastingNote.count", -1) do
      delete tasting_note_url(note)
    end
    assert_redirected_to tasting_notes_url
  end
end
