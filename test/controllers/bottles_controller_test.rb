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
    assert_select "a[href=?]", new_watch_list_entry_path(watch_list_entry: { watchable_type: "Vintage", watchable_id: @vintage.id }), text: "Add to Watch List"
    assert_select "a[href=?]", new_tasting_note_path(tasting_note: { tasteable_type: "Bottle", tasteable_id: bottle.id }), text: "Tasted This"
    assert_select "a[href=?]", new_tasting_note_path(tasting_note: { tasteable_type: "Bottle", tasteable_id: newer_bottle.id }), text: "Tasted This"
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

  test "show auto print hook is present when redirected after create" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")

    get bottle_url(bottle, print_label: true)

    assert_response :success
    assert_select "[data-controller='print-label'][data-print-label-enabled-value='true'][data-print-label-url-value=?]", label_bottle_path(bottle)
  end

  test "label renders qr code and label content" do
    bottle = Bottle.create!(personal_inventory: "A-001", vintage: @vintage, disposal_method: "Drink")

    get label_bottle_url(bottle)

    assert_response :success
    assert_select "[data-controller='print-page']"
    assert_select ".bottle-label__brand", text: /My Bottles/
    assert_select ".bottle-label__inventory", "A-001"
    assert_includes response.body, "bottle-label__qr"
    assert_includes response.body, "<svg"
    assert_includes response.body, "viewBox="
  end

  test "new preloads vintage from params" do
    alpha_producer = Producer.create!(name: "Alpha Producer")
    alpha_wine = Wine.create!(name: "Alpha Wine", producer: alpha_producer)
    alpha_vintage = Vintage.create!(vintage: "2023", wine: alpha_wine)

    get new_bottle_url(bottle: { vintage_id: @vintage.id })

    assert_response :success
    assert_select "select[name='bottle[vintage_id]'] option[selected][value=?]", @vintage.id
    assert_select "select[name='bottle[vintage_id]'] option", "Producer - Estate Red (2024)"
    assert_select "select[name='bottle[cellarable_selection]'] option", "Not Cellared"

    option_texts = css_select("select[name='bottle[vintage_id]'] option").map(&:text)
    assert_operator option_texts.index("Alpha Producer - Alpha Wine (2023)"), :<,
      option_texts.index("Producer - Estate Red (2024)")
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
end
