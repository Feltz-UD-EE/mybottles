class CreateCoreWineTables < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :producers, id: :uuid, comment: "Producers are individual, co-ops, corporations, and other entities that make wine. They may or may not own land with grapes. They may use their own grapes, purchased grapes, or a combination of the two. Producers typically, though not always, make more than one wine." do |t|
      t.text :name, null: false, comment: "The legal trade name of the producer"
      t.text :address, comment: "The mailing address of the producer"
      t.text :email, comment: "The contact email address of the producer"
      t.text :website, comment: "The public website address of the producer"
      t.text :phone, comment: "The contact phone number of the producer"

      t.timestamps
    end

    add_check_constraint :producers,
      "email IS NULL OR email = '' OR email ~* '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$'",
      name: "chk_producers_email_format"
    add_check_constraint :producers,
      "website IS NULL OR website = '' OR website ~* '^https?://[^[:space:]]+$'",
      name: "chk_producers_website_http_url"

    create_table :wines, id: :uuid, comment: "Wines are named wine brands. A wine belongs to a producer." do |t|
      t.text :name, null: false, comment: "The legal trade name of the wine"
      t.text :description, comment: "A description of the wine"
      t.references :producer, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, comment: "The producer of the wine"
      t.text :style, comment: "The type of wine: still, sparkling, fortified, flavored"
      t.text :color, comment: "The color of wine: red, white, rosé, orange"
      t.text :appellation, comment: "The wine-growing region of the wine"

      t.timestamps
    end

    add_check_constraint :wines,
      "style IS NULL OR style IN ('Still', 'Sparkling', 'Fortified', 'Flavored')",
      name: "chk_wines_style"
    add_check_constraint :wines,
      "color IS NULL OR color IN ('Red', 'White', 'Rosé', 'Orange')",
      name: "chk_wines_color"

    create_table :vintages, id: :uuid, comment: "Vintages are individual 'editions' of a wine. Vintages are usually named after the year that the grapes are harvested. Because producers sometimes blend across year boundaries, some vintages are edition names or numbers, or are just labelled as \"non-vintage\"." do |t|
      t.text :vintage, null: false, comment: "The vintage labelled"
      t.references :wine, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, comment: "The wine"
      t.text :grapes, comment: "The list of grapes in the wine"

      t.timestamps
    end

    create_table :bottles, id: :uuid, comment: "Bottles are individual units of sales of a wine. People purchase and store bottles, often times multiple bottles of a given vintage." do |t|
      t.text :personal_inventory, comment: "An individual numbering code, often for legacy purposes"
      t.references :vintage, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, comment: "The vintage"
      t.date :purchase_date, comment: "The date the bottle was purchased or otherwise acquired"
      t.text :purchase_source, comment: "The retailer or other location that the bottle was purchased from"
      t.decimal :list_price, precision: 10, scale: 2, comment: "The list price of the bottle at time of purchase"
      t.decimal :discount_price, precision: 10, scale: 2, comment: "The discounted price of the bottle"
      t.text :notes, comment: "Any notes about the bottle or the purchase experience"
      t.date :disposal_date, comment: "The date the bottle was consumed, given away, sold, or otherwise disposed of"
      t.text :disposal_method, comment: "The way in which the bottle was disposed: drink, gift, sale, or spoiled"

      t.timestamps
    end

    add_check_constraint :bottles,
      "disposal_method IS NULL OR disposal_method IN ('Drink', 'Gift', 'Sale', 'Spoiled')",
      name: "chk_bottles_disposal_method"
    add_check_constraint :bottles,
      "purchase_date IS NULL OR disposal_date IS NULL OR disposal_date >= purchase_date",
      name: "chk_bottles_disposal_date_after_purchase_date"
  end
end
