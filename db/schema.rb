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

ActiveRecord::Schema[8.0].define(version: 2026_06_14_160000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "trackable_type"
    t.uuid "trackable_id"
    t.string "owner_type"
    t.uuid "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.uuid "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
  end

  create_table "appellation_grapes", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Appellation grapes record grapes that are permitted in an appellation.", force: :cascade do |t|
    t.uuid "appellation_id", null: false, comment: "The appellation where this grape is permitted"
    t.uuid "grape_id", null: false, comment: "The permitted grape"
    t.text "notes", comment: "Notes about this grape in this appellation"
    t.text "approval_status", default: "Approved", null: false, comment: "Review status for this record"
    t.uuid "created_by_user_id", comment: "User who first created this record"
    t.uuid "approved_by_user_id", comment: "User who approved this record"
    t.datetime "approved_at", comment: "When this record was approved"
    t.uuid "rejected_by_user_id", comment: "User who rejected this record"
    t.datetime "rejected_at", comment: "When this record was rejected"
    t.uuid "merged_into_id", comment: "Canonical record this duplicate was merged into"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appellation_id", "grape_id"], name: "index_appellation_grapes_on_appellation_and_grape", unique: true, where: "(approval_status <> 'Merged'::text)"
    t.index ["appellation_id"], name: "index_appellation_grapes_on_appellation_id"
    t.index ["approved_by_user_id"], name: "index_appellation_grapes_on_approved_by_user_id"
    t.index ["created_by_user_id"], name: "index_appellation_grapes_on_created_by_user_id"
    t.index ["grape_id"], name: "index_appellation_grapes_on_grape_id"
    t.index ["merged_into_id"], name: "index_appellation_grapes_on_merged_into_id"
    t.index ["rejected_by_user_id"], name: "index_appellation_grapes_on_rejected_by_user_id"
    t.check_constraint "approval_status = ANY (ARRAY['Pending'::text, 'Approved'::text, 'Rejected'::text, 'Merged'::text])", name: "appellation_grapes_approval_status_check"
  end

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
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.index ["cellar_id"], name: "index_bays_on_cellar_id"
    t.index ["user_id"], name: "index_bays_on_user_id"
  end

  create_table "bins", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "A bin is a large, unstructured storage element within a cellar. A bin is typically, though not always, used to store multiple bottles of the same vintage.", force: :cascade do |t|
    t.uuid "cellar_id", null: false, comment: "What cellar the bin is located in"
    t.text "label", comment: "The nametag or other label applied to the bin"
    t.text "location", comment: "Where the bin is located within the cellar"
    t.text "notes", comment: "Any other descriptive information about the bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.index ["cellar_id"], name: "index_bins_on_cellar_id"
    t.index ["user_id"], name: "index_bins_on_user_id"
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
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.text "auto_inventory", comment: "System-generated bottle inventory code used when no personal inventory code is provided"
    t.index ["cellarable_type", "cellarable_id"], name: "index_bottles_on_cellarable"
    t.index ["user_id", "auto_inventory"], name: "index_bottles_on_user_id_and_auto_inventory", unique: true, where: "(auto_inventory IS NOT NULL)"
    t.index ["user_id"], name: "index_bottles_on_user_id"
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
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.index ["user_id"], name: "index_cellars_on_user_id"
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

  create_table "grape_synonyms", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Grape synonyms record that two grape records are known synonyms.", force: :cascade do |t|
    t.uuid "grape_id", null: false, comment: "One grape in the synonym pair"
    t.uuid "synonym_grape_id", null: false, comment: "The other grape in the synonym pair"
    t.text "notes", comment: "Notes about the synonym relationship"
    t.text "approval_status", default: "Approved", null: false, comment: "Review status for this record"
    t.uuid "created_by_user_id", comment: "User who first created this record"
    t.uuid "approved_by_user_id", comment: "User who approved this record"
    t.datetime "approved_at", comment: "When this record was approved"
    t.uuid "rejected_by_user_id", comment: "User who rejected this record"
    t.datetime "rejected_at", comment: "When this record was rejected"
    t.uuid "merged_into_id", comment: "Canonical record this duplicate was merged into"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "LEAST(grape_id, synonym_grape_id), GREATEST(grape_id, synonym_grape_id)", name: "index_grape_synonyms_on_unordered_pair", unique: true, where: "(approval_status <> 'Merged'::text)"
    t.index ["approved_by_user_id"], name: "index_grape_synonyms_on_approved_by_user_id"
    t.index ["created_by_user_id"], name: "index_grape_synonyms_on_created_by_user_id"
    t.index ["grape_id"], name: "index_grape_synonyms_on_grape_id"
    t.index ["merged_into_id"], name: "index_grape_synonyms_on_merged_into_id"
    t.index ["rejected_by_user_id"], name: "index_grape_synonyms_on_rejected_by_user_id"
    t.index ["synonym_grape_id"], name: "index_grape_synonyms_on_synonym_grape_id"
    t.check_constraint "approval_status = ANY (ARRAY['Pending'::text, 'Approved'::text, 'Rejected'::text, 'Merged'::text])", name: "grape_synonyms_approval_status_check"
    t.check_constraint "grape_id <> synonym_grape_id", name: "grape_synonyms_distinct_grapes_check"
  end

  create_table "grapes", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Grapes are botanical wine-making grape varieties or recognized wine-making grape cultivars.", force: :cascade do |t|
    t.text "name", null: false, comment: "The common display name of the grape"
    t.text "notes", comment: "Notes about the grape"
    t.text "approval_status", default: "Approved", null: false, comment: "Review status for this record"
    t.uuid "created_by_user_id", comment: "User who first created this record"
    t.uuid "approved_by_user_id", comment: "User who approved this record"
    t.datetime "approved_at", comment: "When this record was approved"
    t.uuid "rejected_by_user_id", comment: "User who rejected this record"
    t.datetime "rejected_at", comment: "When this record was rejected"
    t.uuid "merged_into_id", comment: "Canonical record this duplicate was merged into"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_user_id"], name: "index_grapes_on_approved_by_user_id"
    t.index ["created_by_user_id"], name: "index_grapes_on_created_by_user_id"
    t.index ["merged_into_id"], name: "index_grapes_on_merged_into_id"
    t.index ["name"], name: "index_grapes_on_name"
    t.index ["rejected_by_user_id"], name: "index_grapes_on_rejected_by_user_id"
    t.check_constraint "approval_status = ANY (ARRAY['Pending'::text, 'Approved'::text, 'Rejected'::text, 'Merged'::text])", name: "grapes_approval_status_check"
  end

  create_table "producers", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Producers are individual, co-ops, corporations, and other entities that make wine. They may or may not own land with grapes. They may use their own grapes, purchased grapes, or a combination of the two. Producers typically, though not always, make more than one wine.", force: :cascade do |t|
    t.text "name", null: false, comment: "The legal trade name of the producer"
    t.text "address", comment: "The mailing address of the producer"
    t.text "email", comment: "The contact email address of the producer"
    t.text "website", comment: "The public website address of the producer"
    t.text "phone", comment: "The contact phone number of the producer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "approval_status", default: "Approved", null: false, comment: "Review status for this record"
    t.uuid "created_by_user_id", comment: "User who first created this record"
    t.uuid "approved_by_user_id", comment: "User who approved this record"
    t.datetime "approved_at", comment: "When this record was approved"
    t.uuid "rejected_by_user_id", comment: "User who rejected this record"
    t.datetime "rejected_at", comment: "When this record was rejected"
    t.uuid "merged_into_id", comment: "Canonical record this duplicate was merged into"
    t.index ["approved_by_user_id"], name: "index_producers_on_approved_by_user_id"
    t.index ["created_by_user_id"], name: "index_producers_on_created_by_user_id"
    t.index ["merged_into_id"], name: "index_producers_on_merged_into_id"
    t.index ["rejected_by_user_id"], name: "index_producers_on_rejected_by_user_id"
    t.check_constraint "approval_status = ANY (ARRAY['Pending'::text, 'Approved'::text, 'Rejected'::text, 'Merged'::text])", name: "producers_approval_status_check"
    t.check_constraint "email IS NULL OR email = ''::text OR email ~* '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$'::text", name: "chk_producers_email_format"
    t.check_constraint "website IS NULL OR website = ''::text OR website ~* '^https?://[^[:space:]]+$'::text", name: "chk_producers_website_http_url"
  end

  create_table "proposed_changes", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Proposed changes are pending edits or merge proposals for community-curated canonical data.", force: :cascade do |t|
    t.text "target_type", null: false, comment: "The model type being changed"
    t.uuid "target_id", null: false, comment: "The record being changed"
    t.uuid "proposed_by_user_id", null: false, comment: "User who submitted the proposal"
    t.uuid "reviewed_by_user_id", comment: "User who reviewed the proposal"
    t.text "status", default: "Pending", null: false, comment: "Review status"
    t.text "action", null: false, comment: "What kind of proposal this is"
    t.jsonb "proposed_attributes", default: {}, null: false, comment: "Proposed attribute values"
    t.jsonb "original_attributes", default: {}, null: false, comment: "Canonical values when the proposal was submitted"
    t.jsonb "reviewer_attributes", comment: "Reviewer-edited values applied at approval"
    t.text "duplicate_of_type", comment: "Proposed canonical duplicate target type"
    t.uuid "duplicate_of_id", comment: "Proposed canonical duplicate target id"
    t.text "review_notes", comment: "Notes from reviewer"
    t.datetime "submitted_at", null: false, comment: "When the proposal was submitted"
    t.datetime "reviewed_at", comment: "When the proposal was reviewed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["duplicate_of_type", "duplicate_of_id"], name: "idx_on_duplicate_of_type_duplicate_of_id_725bbdb17c"
    t.index ["proposed_by_user_id"], name: "index_proposed_changes_on_proposed_by_user_id"
    t.index ["reviewed_by_user_id"], name: "index_proposed_changes_on_reviewed_by_user_id"
    t.index ["target_type", "target_id"], name: "index_proposed_changes_on_target_type_and_target_id"
    t.check_constraint "action = ANY (ARRAY['Update'::text, 'Merge'::text])", name: "proposed_changes_action_check"
    t.check_constraint "status = ANY (ARRAY['Pending'::text, 'Approved'::text, 'Rejected'::text, 'Superseded'::text, 'Merged'::text, 'Needs More Info'::text])", name: "proposed_changes_status_check"
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
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.index ["shelveable_type", "shelveable_id"], name: "index_shelves_on_shelveable_type_and_shelveable_id"
    t.index ["user_id"], name: "index_shelves_on_user_id"
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
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.index ["tasteable_type", "tasteable_id"], name: "index_tasting_notes_on_tasteable"
    t.index ["user_id"], name: "index_tasting_notes_on_user_id"
  end

  create_table "user_trust_events", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "User trust events track promotions and demotions between trust levels.", force: :cascade do |t|
    t.uuid "user_id", null: false, comment: "The user whose trust level changed"
    t.uuid "actor_id", null: false, comment: "The user who changed the trust level"
    t.text "from_trust_level", null: false, comment: "Trust level before the change"
    t.text "to_trust_level", null: false, comment: "Trust level after the change"
    t.text "action", null: false, comment: "Whether this event is a promotion or demotion"
    t.text "notes", comment: "Optional notes about why the change was made"
    t.datetime "dismissed_at", comment: "When the promoted user dismissed this event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_user_trust_events_on_actor_id"
    t.index ["user_id"], name: "index_user_trust_events_on_user_id"
    t.check_constraint "action = ANY (ARRAY['Promotion'::text, 'Demotion'::text])", name: "user_trust_events_action_check"
    t.check_constraint "from_trust_level = ANY (ARRAY['Basic'::text, 'Trusted'::text, 'Curator'::text, 'System Administrator'::text])", name: "user_trust_events_from_trust_level_check"
    t.check_constraint "to_trust_level = ANY (ARRAY['Basic'::text, 'Trusted'::text, 'Curator'::text, 'System Administrator'::text])", name: "user_trust_events_to_trust_level_check"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Users are people who can sign in, manage private cellar data, and participate in trust-based community data workflows.", force: :cascade do |t|
    t.text "email", default: "", null: false, comment: "The user's email address"
    t.text "encrypted_password", default: "", null: false, comment: "Devise encrypted password"
    t.text "trust_level", default: "Basic", null: false, comment: "The user's trust level"
    t.text "name", comment: "The user's display name"
    t.text "theme_preference", default: "System", null: false, comment: "The user's preferred visual theme"
    t.boolean "print_labels_by_default", default: false, null: false, comment: "Whether bottle creation should print labels by default"
    t.text "reset_password_token", comment: "Token used for password reset"
    t.datetime "reset_password_sent_at", comment: "When password reset instructions were sent"
    t.datetime "remember_created_at", comment: "When the remember-me session was created"
    t.integer "sign_in_count", default: 0, null: false, comment: "Number of sign-ins"
    t.datetime "current_sign_in_at", comment: "Current sign-in timestamp"
    t.datetime "last_sign_in_at", comment: "Previous sign-in timestamp"
    t.text "current_sign_in_ip", comment: "Current sign-in IP"
    t.text "last_sign_in_ip", comment: "Previous sign-in IP"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "invitation_token", comment: "Token used for invitations"
    t.datetime "invitation_created_at", comment: "When an invitation was created"
    t.datetime "invitation_sent_at", comment: "When an invitation was sent"
    t.datetime "invitation_accepted_at", comment: "When an invitation was accepted"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.uuid "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "next_auto_inventory_number", default: 1, null: false, comment: "Next sequential number to use when generating a bottle auto-inventory code"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "theme_preference = ANY (ARRAY['Light'::text, 'Dark'::text, 'System'::text])", name: "users_theme_preference_check"
    t.check_constraint "trust_level = ANY (ARRAY['Basic'::text, 'Trusted'::text, 'Curator'::text, 'System Administrator'::text])", name: "users_trust_level_check"
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.uuid "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vintages", id: :uuid, default: -> { "gen_random_uuid()" }, comment: "Vintages are individual 'editions' of a wine. Vintages are usually named after the year that the grapes are harvested. Because producers sometimes blend across year boundaries, some vintages are edition names or numbers, or are just labelled as \"non-vintage\".", force: :cascade do |t|
    t.text "vintage", null: false, comment: "The vintage labelled"
    t.uuid "wine_id", null: false, comment: "The wine"
    t.text "grapes", comment: "The list of grapes in the wine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "approval_status", default: "Approved", null: false, comment: "Review status for this record"
    t.uuid "created_by_user_id", comment: "User who first created this record"
    t.uuid "approved_by_user_id", comment: "User who approved this record"
    t.datetime "approved_at", comment: "When this record was approved"
    t.uuid "rejected_by_user_id", comment: "User who rejected this record"
    t.datetime "rejected_at", comment: "When this record was rejected"
    t.uuid "merged_into_id", comment: "Canonical record this duplicate was merged into"
    t.index ["approved_by_user_id"], name: "index_vintages_on_approved_by_user_id"
    t.index ["created_by_user_id"], name: "index_vintages_on_created_by_user_id"
    t.index ["merged_into_id"], name: "index_vintages_on_merged_into_id"
    t.index ["rejected_by_user_id"], name: "index_vintages_on_rejected_by_user_id"
    t.index ["wine_id"], name: "index_vintages_on_wine_id"
    t.check_constraint "approval_status = ANY (ARRAY['Pending'::text, 'Approved'::text, 'Rejected'::text, 'Merged'::text])", name: "vintages_approval_status_check"
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
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.index ["user_id"], name: "index_watch_list_entries_on_user_id"
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
    t.uuid "user_id", null: false, comment: "The user who owns this record"
    t.index ["producer_id"], name: "index_wine_clubs_on_producer_id"
    t.index ["user_id"], name: "index_wine_clubs_on_user_id"
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
    t.text "approval_status", default: "Approved", null: false, comment: "Review status for this record"
    t.uuid "created_by_user_id", comment: "User who first created this record"
    t.uuid "approved_by_user_id", comment: "User who approved this record"
    t.datetime "approved_at", comment: "When this record was approved"
    t.uuid "rejected_by_user_id", comment: "User who rejected this record"
    t.datetime "rejected_at", comment: "When this record was rejected"
    t.uuid "merged_into_id", comment: "Canonical record this duplicate was merged into"
    t.index ["approved_by_user_id"], name: "index_wines_on_approved_by_user_id"
    t.index ["created_by_user_id"], name: "index_wines_on_created_by_user_id"
    t.index ["merged_into_id"], name: "index_wines_on_merged_into_id"
    t.index ["producer_id"], name: "index_wines_on_producer_id"
    t.index ["rejected_by_user_id"], name: "index_wines_on_rejected_by_user_id"
    t.check_constraint "approval_status = ANY (ARRAY['Pending'::text, 'Approved'::text, 'Rejected'::text, 'Merged'::text])", name: "wines_approval_status_check"
    t.check_constraint "color IS NULL OR (color = ANY (ARRAY['Red'::text, 'White'::text, 'Rosé'::text, 'Orange'::text]))", name: "chk_wines_color"
    t.check_constraint "style IS NULL OR (style = ANY (ARRAY['Still'::text, 'Sparkling'::text, 'Fortified'::text, 'Flavored'::text]))", name: "chk_wines_style"
  end

  add_foreign_key "appellation_grapes", "appellation_grapes", column: "merged_into_id"
  add_foreign_key "appellation_grapes", "appellations"
  add_foreign_key "appellation_grapes", "grapes"
  add_foreign_key "appellation_grapes", "users", column: "approved_by_user_id"
  add_foreign_key "appellation_grapes", "users", column: "created_by_user_id"
  add_foreign_key "appellation_grapes", "users", column: "rejected_by_user_id"
  add_foreign_key "appellations", "appellations", column: "parent_id", on_delete: :restrict
  add_foreign_key "appellations", "countries", on_delete: :restrict
  add_foreign_key "bays", "cellars", on_delete: :restrict
  add_foreign_key "bays", "users"
  add_foreign_key "bins", "cellars", on_delete: :restrict
  add_foreign_key "bins", "users"
  add_foreign_key "bottles", "users"
  add_foreign_key "bottles", "vintages", on_delete: :restrict
  add_foreign_key "cellars", "users"
  add_foreign_key "grape_synonyms", "grape_synonyms", column: "merged_into_id"
  add_foreign_key "grape_synonyms", "grapes"
  add_foreign_key "grape_synonyms", "grapes", column: "synonym_grape_id"
  add_foreign_key "grape_synonyms", "users", column: "approved_by_user_id"
  add_foreign_key "grape_synonyms", "users", column: "created_by_user_id"
  add_foreign_key "grape_synonyms", "users", column: "rejected_by_user_id"
  add_foreign_key "grapes", "grapes", column: "merged_into_id"
  add_foreign_key "grapes", "users", column: "approved_by_user_id"
  add_foreign_key "grapes", "users", column: "created_by_user_id"
  add_foreign_key "grapes", "users", column: "rejected_by_user_id"
  add_foreign_key "producers", "producers", column: "merged_into_id"
  add_foreign_key "producers", "users", column: "approved_by_user_id"
  add_foreign_key "producers", "users", column: "created_by_user_id"
  add_foreign_key "producers", "users", column: "rejected_by_user_id"
  add_foreign_key "proposed_changes", "users", column: "proposed_by_user_id"
  add_foreign_key "proposed_changes", "users", column: "reviewed_by_user_id"
  add_foreign_key "shelves", "users"
  add_foreign_key "tasting_notes", "users"
  add_foreign_key "user_trust_events", "users"
  add_foreign_key "user_trust_events", "users", column: "actor_id"
  add_foreign_key "vintages", "users", column: "approved_by_user_id"
  add_foreign_key "vintages", "users", column: "created_by_user_id"
  add_foreign_key "vintages", "users", column: "rejected_by_user_id"
  add_foreign_key "vintages", "vintages", column: "merged_into_id"
  add_foreign_key "vintages", "wines", on_delete: :restrict
  add_foreign_key "watch_list_entries", "users"
  add_foreign_key "wine_clubs", "producers", on_delete: :restrict
  add_foreign_key "wine_clubs", "users"
  add_foreign_key "wines", "producers", on_delete: :restrict
  add_foreign_key "wines", "users", column: "approved_by_user_id"
  add_foreign_key "wines", "users", column: "created_by_user_id"
  add_foreign_key "wines", "users", column: "rejected_by_user_id"
  add_foreign_key "wines", "wines", column: "merged_into_id"
end
