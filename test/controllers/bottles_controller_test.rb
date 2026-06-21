require "test_helper"

class BottlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    @vintage = Vintage.create!(vintage: "2024", wine: wine)
  end

  test "lists bottles with dynamic table UI" do
    cellar = Cellar.create!(name: "Main")
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, purchase_date: Date.new(2026, 6, 6), disposal_method: "Drink", cellarable: cellar)
    newer_bottle = Bottle.create!(personal_inventory: "A-002", vintage: @vintage, purchase_date: Date.new(2026, 6, 7), disposal_method: "Drink")
    TastingNote.create!(tasteable: bottle, date: Date.new(2026, 6, 8), overall: "Bright")

    get bottles_url

    assert_response :success
    assert_select "h1", "Bottles"
    assert_select "[data-controller='table']"
    assert_select "td", "A-001"
    assert_select "td", "Producer - Estate Red - 2024"
    assert_select "td", "2026-06-06"
    assert_select "td", "Main"
    assert_select "td", "Not Cellared"
    assert_select "tbody tr:first-child td:first-child", "A-002"
    assert_select "th", "Tasted"
    assert_select "th", { text: "In Inventory", count: 0 }
    assert_select "a[href=?]", disposed_bottles_path, text: "Disposed Bottles"
    assert_select "span.tasted-checkmark[aria-label='Tasted']", count: 1
    assert_select "a[href=?]", new_watch_list_entry_path(watch_list_entry: { watchable_type: "Vintage", watchable_id: @vintage.id }), text: "Add to Watch List"
    assert_select "a[href=?]", new_tasting_note_path(tasting_note: { tasteable_type: "Bottle", tasteable_id: bottle.id }), text: "Tasted This"
    assert_select "a[href=?]", new_tasting_note_path(tasting_note: { tasteable_type: "Bottle", tasteable_id: newer_bottle.id }), text: "Tasted This"
  end

  test "index includes only bottles in inventory" do
    Bottle.create!(personal_inventory: "A-001", vintage: @vintage, purchase_date: Date.new(2026, 6, 6))
    Bottle.create!(personal_inventory: "A-002", vintage: @vintage, purchase_date: Date.new(2026, 6, 7), disposal_date: Date.new(2026, 6, 8), disposal_method: "Drink")

    get bottles_url

    assert_response :success
    assert_select "td", "A-001"
    assert_select "td", { text: "A-002", count: 0 }
  end

  test "disposed lists disposed bottles by disposal date descending" do
    Bottle.create!(personal_inventory: "A-001", vintage: @vintage, purchase_date: Date.new(2026, 6, 6))
    older_bottle = Bottle.create!(personal_inventory: "A-002", vintage: @vintage, purchase_date: Date.new(2026, 6, 7), disposal_date: Date.new(2026, 6, 8), disposal_method: "Drink")
    newer_bottle = Bottle.create!(personal_inventory: "A-003", vintage: @vintage, purchase_date: Date.new(2026, 6, 7), disposal_date: Date.new(2026, 6, 9), disposal_method: "Gift")
    TastingNote.create!(tasteable: newer_bottle, date: Date.new(2026, 6, 9), overall: "Shared")

    get disposed_bottles_url

    assert_response :success
    assert_select "h1", "Disposed Bottles"
    assert_select "a[href=?]", bottles_path, text: "Back to bottles"
    assert_select "select[name='disposal_method'] option", "All"
    Bottle::DISPOSAL_METHODS.each do |method|
      assert_select "select[name='disposal_method'] option[value=?]", method, text: method
    end
    assert_select "td", { text: "A-001", count: 0 }
    assert_select "td", "A-002"
    assert_select "td", "A-003"
    assert_select "td", "2026-06-08"
    assert_select "td", "2026-06-09"
    assert_select "td", "Drink"
    assert_select "td", "Gift"
    assert_select "span.tasted-checkmark[aria-label='Tasted']", count: 1
    assert_operator response.body.index(newer_bottle.personal_inventory), :<, response.body.index(older_bottle.personal_inventory)
  end

  test "disposed filters bottles by disposal method" do
    Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_date: Date.new(2026, 6, 8), disposal_method: "Drink")
    Bottle.create!(personal_inventory: "A-002", vintage: @vintage, disposal_date: Date.new(2026, 6, 9), disposal_method: "Gift")

    get disposed_bottles_url(disposal_method: "Gift")

    assert_response :success
    assert_select "select[name='disposal_method'] option[selected][value='Gift']", "Gift"
    assert_select "td", { text: "A-001", count: 0 }
    assert_select "td", "A-002"
  end

  test "disposed all option does not filter by disposal method" do
    Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_date: Date.new(2026, 6, 8), disposal_method: "Drink")
    Bottle.create!(personal_inventory: "A-002", vintage: @vintage, disposal_date: Date.new(2026, 6, 9), disposal_method: "Gift")

    get disposed_bottles_url(disposal_method: "")

    assert_response :success
    assert_select "td", "A-001"
    assert_select "td", "A-002"
  end

  test "show title includes producer wine and vintage and tasting note launch" do
    cellar = Cellar.create!(name: "Main")
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink", cellarable: cellar)

    get bottle_url(bottle)

    assert_response :success
    assert_select "h1", "Producer - Estate Red - 2024"
    assert_select "dt", "Location"
    assert_select "dd", "Main"
    assert_select "a[href=?]", label_bottle_path(bottle), text: "Print labels"
    assert_select "a[href=?]", new_watch_list_entry_path(watch_list_entry: { watchable_type: "Vintage", watchable_id: @vintage.id }), text: "Add to Watch List"
    assert_select "a[href=?]", new_tasting_note_path(tasting_note: { tasteable_type: "Bottle", tasteable_id: bottle.id }), text: "Tasted This"
  end

  test "show lists tasting notes for same vintage by date descending" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")
    other_bottle = Bottle.create!(personal_inventory: "A-002", vintage: @vintage, disposal_method: "Drink")
    other_vintage = Vintage.create!(vintage: "2023", wine: @vintage.wine)
    other_vintage_bottle = Bottle.create!(personal_inventory: "B-001", vintage: other_vintage, disposal_method: "Drink")
    older_note = TastingNote.create!(tasteable: bottle, date: Date.new(2026, 6, 1), overall: "Current bottle note")
    newer_note = TastingNote.create!(tasteable: other_bottle, date: Date.new(2026, 6, 3), overall: "Other bottle note")
    vintage_note = TastingNote.create!(tasteable: @vintage, date: Date.new(2026, 6, 2), overall: "Vintage note")
    TastingNote.create!(tasteable: other_vintage_bottle, date: Date.new(2026, 6, 4), overall: "Wrong vintage note")

    get bottle_url(bottle)

    assert_response :success
    assert_select "h2", "Tasting Notes"
    assert_select "a[href=?]", tasting_note_path(older_note), text: "Show"
    assert_select "a[href=?]", tasting_note_path(newer_note), text: "Show"
    assert_select "a[href=?]", tasting_note_path(vintage_note), text: "Show"
    assert_select "td", text: "Wrong vintage note", count: 0
    assert_operator response.body.index("Other bottle note"), :<, response.body.index("Vintage note")
    assert_operator response.body.index("Vintage note"), :<, response.body.index("Current bottle note")
    assert_select "td", "This bottle (A-001)"
    assert_select "td", "Bottle A-002"
    assert_select "td", "Vintage 2024"
  end

  test "show auto print hook is present when redirected after create" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")

    get bottle_url(bottle, print_label: true)

    assert_response :success
    assert_select "[data-controller='print-label'][data-print-label-enabled-value='true'][data-print-label-url-value=?]", label_bottle_path(bottle)
  end

  test "show auto print hook can target batch labels" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")
    batch_path = labels_bottles_path(ids: bottle.id)

    get bottle_url(bottle, print_label: true, print_label_url: batch_path)

    assert_response :success
    assert_select "[data-controller='print-label'][data-print-label-enabled-value='true'][data-print-label-url-value=?]", batch_path
  end

  test "show auto print hook ignores external print label urls" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")

    get bottle_url(bottle, print_label: true, print_label_url: "https://example.com/labels")

    assert_response :success
    assert_select "[data-controller='print-label'][data-print-label-enabled-value='true'][data-print-label-url-value=?]", label_bottle_path(bottle)
  end

  test "label renders qr code and label content" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")

    get label_bottle_url(bottle)

    assert_response :success
    assert_select "[data-controller='print-page']"
    assert_select ".bottle-label__brand", text: /mybottles\.tech/
    assert_select ".bottle-label__qr[aria-label=?]", "QR code for https://mybottles.tech/bottles/#{bottle.id}"
    assert_select ".bottle-label__inventory", "A-001"
    assert_includes response.body, "bottle-label__qr"
    assert_includes response.body, "<svg"
    assert_includes response.body, "viewBox="
  end

  test "label renders generated inventory when personal inventory is blank" do
    bottle = Bottle.create!(vintage: @vintage, disposal_method: "Drink")

    get label_bottle_url(bottle)

    assert_response :success
    assert_equal "000001", bottle.reload.auto_inventory
    assert_select ".bottle-label__inventory", "000-001"
  end

  test "label renders personal inventory instead of generated inventory when both exist" do
    bottle = Bottle.create!(vintage: @vintage, disposal_method: "Drink")
    bottle.update!(personal_inventory: "A-001")

    get label_bottle_url(bottle)

    assert_response :success
    assert_equal "000001", bottle.reload.auto_inventory
    assert_select ".bottle-label__inventory", "A-001"
    assert_select ".bottle-label__inventory", { text: "000-001", count: 0 }
  end

  test "labels renders multiple labels in submitted order" do
    first_bottle = Bottle.create!(vintage: @vintage, disposal_method: "Drink")
    second_bottle = Bottle.create!(vintage: @vintage, disposal_method: "Drink")

    get labels_bottles_url(ids: [ second_bottle.id, first_bottle.id ].join(","))

    assert_response :success
    assert_select "[data-controller='print-page']"
    assert_select ".bottle-label", count: 2
    assert_operator response.body.index(second_bottle.auto_inventory_display), :<, response.body.index(first_bottle.auto_inventory_display)
  end

  test "new preloads vintage from params" do
    alpha_producer = Producer.create!(name: "Alpha Producer")
    alpha_wine = Wine.create!(name: "Alpha Wine", producer: alpha_producer)
    alpha_vintage = Vintage.create!(vintage: "2023", wine: alpha_wine)

    get new_bottle_url(bottle: { vintage_id: @vintage.id })

    assert_response :success
    assert_select "select[name='bottle[vintage_id]'] option[selected][value=?]", @vintage.id
    assert_select "input[name='bottle[quantity]'][value='1']"
    assert_select "select[name='bottle[vintage_id]'] option", "Producer - Estate Red (2024)"
    assert_select "select[name='bottle[cellarable_selection]'] option", "Not Cellared"

    option_texts = css_select("select[name='bottle[vintage_id]'] option").map(&:text)
    assert_operator option_texts.index("Alpha Producer - Alpha Wine (2023)"), :<,
      option_texts.index("Producer - Estate Red (2024)")
  end

  test "edit does not show quantity field" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")

    get edit_bottle_url(bottle)

    assert_response :success
    assert_select "input[name='bottle[quantity]']", count: 0
  end

  test "creates updates and deletes bottle" do
    cellar = Cellar.create!(name: "Main")
    bin = Bin.create!(cellar: cellar, label: "Everyday Spanish")

    assert_difference("Bottle.count", 1) do
      post bottles_url, params: { bottle: { personal_inventory: "A-002", vintage_id: @vintage.id, purchase_date: "2026-06-06", list_price: "25.00", disposal_method: "Drink", cellarable_selection: "Cellar:#{cellar.id}" } }
    end

    bottle = Bottle.order(:created_at).last
    assert_redirected_to bottle_url(bottle, print_label: false)
    assert_equal cellar, bottle.cellarable

    patch bottle_url(bottle), params: { bottle: { personal_inventory: "A-003", vintage_id: @vintage.id, discount_price: "20.00", disposal_method: "Gift", disposal_date: "2026-06-07", cellarable_selection: "Bin:#{bin.id}" } }
    assert_redirected_to bottle_url(bottle)
    assert_equal "A-003", bottle.reload.personal_inventory
    assert_equal "Gift", bottle.disposal_method
    assert_equal bin, bottle.cellarable
    assert_not bottle.in_inventory?

    assert_difference("Bottle.count", -1) do
      delete bottle_url(bottle)
    end
    assert_redirected_to bottles_url
  end

  test "creates bottle with generated inventory when personal inventory is blank" do
    assert_difference("Bottle.count", 1) do
      post bottles_url, params: { bottle: { personal_inventory: "", vintage_id: @vintage.id, purchase_date: "2026-06-06" } }
    end

    bottle = Bottle.order(:created_at).last
    assert_redirected_to bottle_url(bottle, print_label: false)
    assert_equal "000001", bottle.auto_inventory
    assert_equal "000-001", bottle.inventory_code
  end

  test "rejects invalid quantity" do
    assert_no_difference("Bottle.count") do
      post bottles_url, params: { bottle: { quantity: "0", vintage_id: @vintage.id } }
    end

    assert_response :unprocessable_entity
    assert_select ".error-messages li", "Quantity must be an integer greater than or equal to 1"
  end

  test "creates multiple bottles with blank personal inventory" do
    cellar = Cellar.create!(name: "Main")

    assert_difference("Bottle.count", 3) do
      post bottles_url, params: { bottle: { quantity: "3", personal_inventory: "", vintage_id: @vintage.id, purchase_date: "2026-06-06", purchase_source: "Shop", list_price: "25.00", disposal_method: "Drink", cellarable_selection: "Cellar:#{cellar.id}" } }
    end

    created_bottles = Bottle.order(:created_at).last(3)
    assert_redirected_to bottle_url(created_bottles.first, print_label: false)
    assert_equal "3 bottles were successfully created.", flash[:notice]
    assert_equal [ "" ], created_bottles.map(&:personal_inventory).uniq
    assert_equal 3, created_bottles.map(&:auto_inventory).uniq.size
    created_bottles.each do |bottle|
      assert_equal @vintage, bottle.vintage
      assert_equal Date.new(2026, 6, 6), bottle.purchase_date
      assert_equal "Shop", bottle.purchase_source
      assert_equal BigDecimal("25.00"), bottle.list_price
      assert_equal "Drink", bottle.disposal_method
      assert_equal cellar, bottle.cellarable
    end
  end

  test "creates multiple bottles with personal inventory only on first bottle" do
    assert_difference("Bottle.count", 3) do
      post bottles_url, params: { bottle: { quantity: "3", personal_inventory: "A-001", vintage_id: @vintage.id, purchase_date: "2026-06-06" } }
    end

    created_bottles = Bottle.order(:created_at).last(3)
    assert_redirected_to bottle_url(created_bottles.first, print_label: false)
    assert_equal "A-001", created_bottles.first.personal_inventory
    assert_nil created_bottles.second.personal_inventory
    assert_nil created_bottles.third.personal_inventory
    assert_equal 2, created_bottles.drop(1).map(&:auto_inventory).uniq.size
    assert_includes flash[:notice], "3 bottles were successfully created."
    assert_includes flash[:notice], "Only the first bottle has the personal inventory code."
    assert_includes flash[:notice], "The remaining 2 bottles do not have their personal inventory code completed"
    assert_includes flash[:notice], "do not print labels for those bottles until after updating their personal inventory code"
  end

  test "failed multi bottle creation does not persist partial bottles" do
    assert_no_difference("Bottle.count") do
      post bottles_url, params: { bottle: { quantity: "3", vintage_id: @vintage.id, cellarable_selection: "Cellar:missing" } }
    end

    assert_response :unprocessable_entity
    assert_select ".error-messages li", "Cellarable is invalid"
  end

  test "automatic label printing opens batch labels when personal inventory is blank" do
    admin_user.update!(print_labels_by_default: true)

    assert_difference("Bottle.count", 2) do
      post bottles_url, params: { bottle: { quantity: "2", personal_inventory: "", vintage_id: @vintage.id } }
    end

    created_bottles = Bottle.order(:created_at).last(2)
    batch_path = labels_bottles_path(ids: created_bottles.map(&:id).join(","))
    assert_redirected_to bottle_url(created_bottles.first, print_label: true, print_label_url: batch_path)
  end

  test "automatic label printing opens only first label when personal inventory is present" do
    admin_user.update!(print_labels_by_default: true)

    assert_difference("Bottle.count", 2) do
      post bottles_url, params: { bottle: { quantity: "2", personal_inventory: "A-001", vintage_id: @vintage.id } }
    end

    created_bottles = Bottle.order(:created_at).last(2)
    assert_redirected_to bottle_url(created_bottles.first, print_label: true)
  end
end
