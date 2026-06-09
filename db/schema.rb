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

ActiveRecord::Schema[8.0].define(version: 2026_06_08_160000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "appellations", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "An appellation is a legally defined, named region for wine production. The appellation system for wines was first pioneered in France. All wines either have an appellation, or as a default, a country. Appellations are often nested within each other.", force: :cascade do |t|
    t.uuid "country_id", null: false, comment: "What country the appellation is in"
    t.text "name", null: false, comment: "The nametag or other label applied to the bin"
    t.text "degree", comment: "The legal category of appellations - many countries have two or more"
    t.uuid "parent_id", comment: "The parent appellation, if present"
    t.text "notes", comment: "Any other descriptive information about the appellation"
    t.boolean "auto_generated", default: false, null: false, comment: "Whether the information for this appellation was LLM-generated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_appellations_on_country_id"
    t.index ["parent_id"], name: "index_appellations_on_parent_id"
  end

  create_table "bays", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "A bay is a section of a cellar. Bays are composed of racks of shelves.", force: :cascade do |t|
    t.uuid "cellar_id", null: false, comment: "What cellar the bay is located in"
    t.text "label", comment: "The nametag or other label applied to the bay"
    t.text "location", comment: "Where the bay is located within the cellar"
    t.text "notes", comment: "Any other descriptive information about the bay"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cellar_id"], name: "index_bays_on_cellar_id"
  end

  create_table "bins", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "A bin is a large, unstructured storage element within a cellar. A bin is typically, though not always, used to store multiple bottles of the same vintage.", force: :cascade do |t|
    t.uuid "cellar_id", null: false, comment: "What cellar the bin is located in"
    t.text "label", comment: "The nametag or other label applied to the bin"
    t.text "location", comment: "Where the bin is located within the cellar"
    t.text "notes", comment: "Any other descriptive information about the bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cellar_id"], name: "index_bins_on_cellar_id"
  end

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
    t.string "cellarable_type"
    t.uuid "cellarable_id", comment: "Where this bottle is cellared"
    t.index ["cellarable_type", "cellarable_id"], name: "index_bottles_on_cellarable"
    t.index ["vintage_id"], name: "index_bottles_on_vintage_id"
    t.check_constraint "cellarable_type IS NULL OR (cellarable_type::text = ANY (ARRAY['Cellar'::character varying, 'Bin'::character varying, 'Shelf'::character varying]::text[]))", name: "chk_bottles_cellarable_type"
    t.check_constraint "disposal_method IS NULL OR (disposal_method = ANY (ARRAY['Drink'::text, 'Gift'::text, 'Sale'::text, 'Spoiled'::text]))", name: "chk_bottles_disposal_method"
    t.check_constraint "purchase_date IS NULL OR disposal_date IS NULL OR disposal_date >= purchase_date", name: "chk_bottles_disposal_date_after_purchase_date"
  end

  create_table "cellars", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Cellars are places to store wine. A user may have one or more cellars. Cellars have a variety of sub-elements - bays, bins, shelves. \"Cellar\" is also a way to describe other kinds of storage systems and locations, such as wine refrigerators.", force: :cascade do |t|
    t.text "name", null: false, comment: "A convenient name for a cellar"
    t.text "location", comment: "Where the cellar is located"
    t.text "notes", comment: "Any other descriptive information about the cellar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Countries are just what they say they are - the top political bodies.", force: :cascade do |t|
    t.text "name", null: false, comment: "The common name for the country"
    t.text "fullname", comment: "The full legal name of the country"
    t.text "iso2", null: false, comment: "The ISO-2 country code for the country"
    t.text "iso3", null: false, comment: "The ISO-3 country code for the country"
    t.text "notes", comment: "Other descriptive notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "shelves", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "A shelf is a horizontal surface or rack suitable for placing bottles. Shelves often have small separators so that bottles are not touching each other and can be drawn out easily. Shelves may be one bottle deep or sometimes multiple bottles deep.", force: :cascade do |t|
    t.string "shelveable_type", null: false, comment: "Whether this shelf belongs to a cellar or a bay"
    t.uuid "shelveable_id", null: false, comment: "The cellar or bay this shelf belongs to"
    t.text "number", comment: "A numeric or semi-numeric label for the shelf for sorting purposes"
    t.text "label", comment: "Any label that might be applied to a shelf; this may change over time"
    t.text "depth", default: "Single", null: false, comment: "Whether the shelf is a single bottle deep or multiple"
    t.text "notes", comment: "Any other descriptive information about the shelf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shelveable_type", "shelveable_id"], name: "index_shelves_on_shelveable_type_and_shelveable_id"
    t.check_constraint "depth = ANY (ARRAY['Single'::text, 'Multiple'::text])", name: "chk_shelves_depth"
    t.check_constraint "shelveable_type::text = ANY (ARRAY['Cellar'::character varying, 'Bay'::character varying]::text[])", name: "chk_shelves_shelveable_type"
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

  add_foreign_key "appellations", "appellations", column: "parent_id", on_delete: :restrict
  add_foreign_key "appellations", "countries", on_delete: :restrict
  add_foreign_key "bays", "cellars", on_delete: :restrict
  add_foreign_key "bins", "cellars", on_delete: :restrict
  add_foreign_key "bottles", "vintages", on_delete: :restrict
  add_foreign_key "vintages", "wines", on_delete: :restrict
  add_foreign_key "wine_clubs", "producers", on_delete: :restrict
  add_foreign_key "wines", "producers", on_delete: :restrict
end
