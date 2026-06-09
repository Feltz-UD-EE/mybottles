require "bigdecimal"
require "csv"
require "date"

PURCHASE_SEED_PATH = Rails.root.join("db/seeds/purchases.csv")
TASTING_NOTE_SEED_PATH = Rails.root.join("db/seeds/tasting_notes.csv")

Current.user = User.bootstrap_system_administrator!

def seed_blank(value)
  value = value.to_s.strip
  value.empty? ? nil : value
end

def seed_date(value)
  value = seed_blank(value)
  value ? Date.iso8601(value) : nil
end

def seed_decimal(value)
  value = seed_blank(value)
  value ? BigDecimal(value) : nil
end

def seed_boolean(value)
  value = seed_blank(value)
  return true if value == "true"
  return false if value == "false"

  nil
end

purchase_rows = CSV.read(PURCHASE_SEED_PATH, headers: true)
seed_inventory_codes = purchase_rows.map { |row| seed_blank(row["personal_inventory"]) }.compact

Bottle
  .where("personal_inventory ~ ?", "^[MR][0-9]{2}-")
  .where.not(personal_inventory: seed_inventory_codes)
  .destroy_all

purchase_rows.each do |row|
  producer = Producer.find_or_create_by!(name: seed_blank(row["producer_name"]))

  wine = Wine.find_or_initialize_by(
    producer: producer,
    name: seed_blank(row["wine_name"])
  )
  wine.appellation = seed_blank(row["appellation"])
  wine.save!

  vintage = Vintage.find_or_initialize_by(
    wine: wine,
    vintage: seed_blank(row["vintage"])
  )
  vintage.save!

  bottle = Bottle.find_or_initialize_by(
    personal_inventory: seed_blank(row["personal_inventory"])
  )
  bottle.assign_attributes(
    vintage: vintage,
    purchase_date: seed_date(row["purchase_date"]),
    purchase_source: seed_blank(row["purchase_source"]),
    list_price: seed_decimal(row["list_price"]),
    discount_price: seed_decimal(row["discount_price"]),
    notes: seed_blank(row["notes"]),
    disposal_date: seed_date(row["disposal_date"]),
    disposal_method: seed_blank(row["disposal_method"])
  )
  bottle.save!
end

if TASTING_NOTE_SEED_PATH.exist?
  CSV.foreach(TASTING_NOTE_SEED_PATH, headers: true) do |row|
    bottle = Bottle.find_by!(personal_inventory: seed_blank(row["personal_inventory"]))

    tasting_note = TastingNote.find_or_initialize_by(
      tasteable: bottle,
      date: seed_date(row["date"]),
      overall: seed_blank(row["overall"])
    )
    tasting_note.assign_attributes(
      setting: seed_blank(row["setting"]),
      temperature: seed_blank(row["temperature"]),
      pairing: seed_blank(row["pairing"]),
      color: seed_blank(row["color"]),
      nose: seed_blank(row["nose"]),
      palate: seed_blank(row["palate"]),
      score: seed_decimal(row["score"]),
      buy: seed_boolean(row["buy"])
    )
    tasting_note.save!
  end
end
