require "test_helper"

class TastingNoteTest < ActiveSupport::TestCase
  test "requires date and tasteable and allows blank buy" do
    note = TastingNote.new(date: nil)

    assert_not note.valid?
    assert_includes note.errors[:date], "can't be blank"
    assert_includes note.errors[:tasteable], "must exist"

    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    note = TastingNote.new(date: Date.new(2026, 6, 7), tasteable: vintage)

    assert note.valid?
    assert_nil note.buy
  end

  test "formats tasteable names for vintage and bottle notes" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: vintage)

    vintage_note = TastingNote.create!(date: Date.new(2026, 6, 7), tasteable: vintage)
    bottle_note = TastingNote.create!(date: Date.new(2026, 6, 7), tasteable: bottle)

    assert_equal "Producer - Estate Red - 2024", vintage_note.tasteable_name
    assert_equal "Producer - Estate Red - 2024", bottle_note.tasteable_name
    assert_equal "A-001 - Producer - Estate Red - 2024", bottle.inventory_display_name
  end
end
