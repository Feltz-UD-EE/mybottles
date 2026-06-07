# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_07_133000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "bottles", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Bottles are individual units of sales of a wine. People purchase and store bottles, often times multiple bottles of a given vintage.", force: :cascade do |t|
    t.text "personal_inventory", comment: "An individual numbering code, often for legacy purposes"
    t.uuid "vintage_id", null: false, comment: "The vintage"
    t.date "purchase_date", comment: "The date the bottle was purchased or otherwise acquired"
    t.text "purchase_source", comment: "The retailer or other location that the bottle was purchased from"
    t.decimal "list_price", precision: 10, scale: 2, comment: "The list price of the bottle at time of purchase"
    t.decimal "discount_price", precision: 10, scale: 2, comment: "The discounted price of the bottle"
    t.text "notes", comment: "Any notes about the bottle or the purchase experience"
    t.date "disposal_date", comment: "The date the bottle was consumed, given away, sold, or otherwise disposed of"
    t.text "disposal_method", comment: "The way in which the bottle was disposed: drink, gift, sale, or spoiled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vintage_id"], name: "index_bottles_on_vintage_id"
    t.check_constraint "disposal_method IS NULL OR (disposal_method = ANY (ARRAY['Drink'::text, 'Gift'::text, 'Sale'::text, 'Spoiled'::text]))", name: "chk_bottles_disposal_method"
    t.check_constraint "purchase_date IS NULL OR disposal_date IS NULL OR disposal_date >= purchase_date", name: "chk_bottles_disposal_date_after_purchase_date"
  end

  create_table "producers", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Producers are individual, co-ops, corporations, and other entities that make wine. They may or may not own land with grapes. They may use their own grapes, purchased grapes, or a combination of the two. Producers typically, though not always, make more than one wine.", force: :cascade do |t|
    t.text "name", null: false, comment: "The legal trade name of the producer"
    t.text "address", comment: "The mailing address of the producer"
    t.text "email", comment: "The contact email address of the producer"
    t.text "website", comment: "The public website address of the producer"
    t.text "phone", comment: "The contact phone number of the producer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "email IS NULL OR email = ''::text OR email ~* '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$'::text", name: "chk_producers_email_format"
    t.check_constraint "website IS NULL OR website = ''::text OR website ~* '^https?://[^[:space:]]+$'::text", name: "chk_producers_website_http_url"
  end

  create_table "tasting_notes", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Tasting Notes are personal notes about tasting wine - from a particular bottle, or from a representative wine & vintage at a winery or retailer.", force: :cascade do |t|
    t.string "tasteable_type", null: false
    t.uuid "tasteable_id", null: false, comment: "The bottle or vintage being tasted"
    t.date "date", null: false, comment: "The date the tasting took place"
    t.text "setting", comment: "The setting where the tasting took place"
    t.text "temperature", comment: "The temperature of the wine"
    t.text "pairing", comment: "Any accompanying food"
    t.text "color", comment: "The color of the wine"
    t.text "nose", comment: "The aromatic elements of the wine"
    t.text "palate", comment: "The taste elements of the wine"
    t.text "overall", comment: "The overall impression of the wine"
    t.decimal "score", precision: 10, scale: 1, comment: "The personal numeric score given to the wine (optional)"
    t.boolean "buy", comment: "Should I buy this wine (or buy it again if the tasting note refers to a bottle)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tasteable_type", "tasteable_id"], name: "index_tasting_notes_on_tasteable"
  end

  create_table "vintages", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Vintages are individual 'editions' of a wine. Vintages are usually named after the year that the grapes are harvested. Because producers sometimes blend across year boundaries, some vintages are edition names or numbers, or are just labelled as \"non-vintage\".", force: :cascade do |t|
    t.text "vintage", null: false, comment: "The vintage labelled"
    t.uuid "wine_id", null: false, comment: "The wine"
    t.text "grapes", comment: "The list of grapes in the wine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wine_id"], name: "index_vintages_on_wine_id"
  end

  create_table "watch_list_entries", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Watch list entries are vintages, wines, or general information about wines I want to purchase in the future.", force: :cascade do |t|
    t.string "watchable_type"
    t.uuid "watchable_id", comment: "The wine or vintage to watch for"
    t.text "description", null: false, comment: "The motivation or justification for looking for this wine"
    t.text "quantity", comment: "How much to purchase"
    t.text "caveat", comment: "Description of why not to buy the wine if it is available - too expensive, bad vintage, etc."
    t.text "notes", comment: "Any additional information about this entry, including exclusive retailers, date of availability, etc."
    t.datetime "deleted_at", comment: "When this watch list entry was soft-deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["watchable_type", "watchable_id"], name: "index_watch_list_entries_on_watchable"
  end

  create_table "wine_clubs", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Wine clubs are subscription memberships offered by wineries that include such features as discounts, free or reduced shipping, access to special wines, preferential treatment at the producer's tasting rooms, invitations to special events, etc. A given producer will typically offer several wine club tiers.", force: :cascade do |t|
    t.uuid "producer_id", null: false, comment: "The producer offering the wine club"
    t.text "tier", comment: "The tier title of the club membership - like gold, reserve, etc."
    t.integer "size", null: false, comment: "The number of bottles in each club order"
    t.text "schedule", null: false, comment: "How often and when wine is delivered"
    t.text "delivery_method", comment: "Whether the wine is shipped or held for pickup"
    t.text "payment_method", comment: "How the club membership is paid for (typically a pre-approved credit card)"
    t.decimal "discount", precision: 5, scale: 2, comment: "What discount the club order is processed at relative to list price"
    t.date "date_joined", comment: "When I joined the wine club"
    t.date "date_left", comment: "When I cancelled my wine club membership"
    t.text "member_id", comment: "An ID supplied by the producer"
    t.text "benefits", comment: "Any other benefits accruing to club members"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["producer_id"], name: "index_wine_clubs_on_producer_id"
    t.check_constraint "delivery_method IS NULL OR (delivery_method = ANY (ARRAY['Shipping'::text, 'Pickup'::text]))", name: "chk_wine_clubs_delivery_method"
    t.check_constraint "discount IS NULL OR discount >= 0::numeric AND discount <= 100::numeric", name: "chk_wine_clubs_discount_percentage"
  end

  create_table "wines", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Wines are named wine brands. A wine belongs to a producer.", force: :cascade do |t|
    t.text "name", null: false, comment: "The legal trade name of the wine"
    t.text "description", comment: "A description of the wine"
    t.uuid "producer_id", null: false, comment: "The producer of the wine"
    t.text "style", comment: "The type of wine: still, sparkling, fortified, flavored"
    t.text "color", comment: "The color of wine: red, white, rosé, orange"
    t.text "appellation", comment: "The wine-growing region of the wine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["producer_id"], name: "index_wines_on_producer_id"
    t.check_constraint "color IS NULL OR (color = ANY (ARRAY['Red'::text, 'White'::text, 'Rosé'::text, 'Orange'::text]))", name: "chk_wines_color"
    t.check_constraint "style IS NULL OR (style = ANY (ARRAY['Still'::text, 'Sparkling'::text, 'Fortified'::text, 'Flavored'::text]))", name: "chk_wines_style"
  end

  add_foreign_key "bottles", "vintages", on_delete: :restrict
  add_foreign_key "vintages", "wines", on_delete: :restrict
  add_foreign_key "wine_clubs", "producers", on_delete: :restrict
  add_foreign_key "wines", "producers", on_delete: :restrict
end
