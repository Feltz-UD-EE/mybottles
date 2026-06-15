require "test_helper"

class TastingNoteTest < ActiveSupport::TestCase
  test "requires date and tasteable and allows blank buy" do
    note = TastingNote.new(date: nil, rating: nil)

    assert_not note.valid?
    assert_includes note.errors[:date], "can't be blank"
    assert_includes note.errors[:tasteable], "must exist"
    assert_includes note.errors[:rating], "can't be blank"

    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    note = TastingNote.new(date: Date.new(2026, 6, 7), tasteable: vintage, rating: 3.25)

    assert note.valid?
    assert_nil note.buy
  end

  test "validates rating range and quarter increments" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)

    [ 0, 0.25, 0.5, 1, 1.25, 2.5, 4.75, 5 ].each do |rating|
      note = TastingNote.new(date: Date.new(2026, 6, 7), tasteable: vintage, rating: rating)
      assert note.valid?, "#{rating} should be valid"
    end

    [ -0.25, 5.25, 3.1, 4.33 ].each do |rating|
      note = TastingNote.new(date: Date.new(2026, 6, 7), tasteable: vintage, rating: rating)
      assert_not note.valid?, "#{rating} should be invalid"
    end
  end

  test "database rejects invalid rating values" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)

    assert_raises(ActiveRecord::StatementInvalid) do
      TastingNote.connection.execute(<<~SQL.squish)
        INSERT INTO tasting_notes (id, tasteable_type, tasteable_id, user_id, date, rating, created_at, updated_at)
        VALUES (gen_random_uuid(), 'Vintage', '#{vintage.id}', '#{admin_user.id}', '2026-06-07', 3.10, NOW(), NOW())
      SQL
    end
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

  test "maps buy checkbox choices and rejects conflicting choices" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)

    note = TastingNote.new(date: Date.new(2026, 6, 7), tasteable: vintage, buy_yes: "1", buy_no: "0")
    assert note.valid?
    assert_equal true, note.buy

    note = TastingNote.new(date: Date.new(2026, 6, 7), tasteable: vintage, buy_yes: "0", buy_no: "1")
    assert note.valid?
    assert_equal false, note.buy

    note = TastingNote.new(date: Date.new(2026, 6, 7), tasteable: vintage, buy_yes: "1", buy_no: "1")
    assert_not note.valid?
    assert_includes note.errors[:buy], "cannot be both Yes and No"
  end
end
