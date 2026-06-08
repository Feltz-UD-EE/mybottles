class CreateCellarTables < ActiveRecord::Migration[8.0]
  def change
    create_table :cellars, id: :uuid, comment: "Cellars are places to store wine. A user may have one or more cellars. Cellars have a variety of sub-elements - bays, bins, shelves. \"Cellar\" is also a way to describe other kinds of storage systems and locations, such as wine refrigerators." do |t|
      t.text :name, null: false, comment: "A convenient name for a cellar"
      t.text :location, comment: "Where the cellar is located"
      t.text :notes, comment: "Any other descriptive information about the cellar"

      t.timestamps
    end

    create_table :bins, id: :uuid, comment: "A bin is a large, unstructured storage element within a cellar. A bin is typically, though not always, used to store multiple bottles of the same vintage." do |t|
      t.references :cellar, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, comment: "What cellar the bin is located in"
      t.text :label, comment: "The nametag or other label applied to the bin"
      t.text :location, comment: "Where the bin is located within the cellar"
      t.text :notes, comment: "Any other descriptive information about the bin"

      t.timestamps
    end

    create_table :bays, id: :uuid, comment: "A bay is a section of a cellar. Bays are composed of racks of shelves." do |t|
      t.references :cellar, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, comment: "What cellar the bay is located in"
      t.text :label, comment: "The nametag or other label applied to the bay"
      t.text :location, comment: "Where the bay is located within the cellar"
      t.text :notes, comment: "Any other descriptive information about the bay"

      t.timestamps
    end

    create_table :shelves, id: :uuid, comment: "A shelf is a horizontal surface or rack suitable for placing bottles. Shelves often have small separators so that bottles are not touching each other and can be drawn out easily. Shelves may be one bottle deep or sometimes multiple bottles deep." do |t|
      t.string :shelveable_type, null: false, comment: "Whether this shelf belongs to a cellar or a bay"
      t.uuid :shelveable_id, null: false, comment: "The cellar or bay this shelf belongs to"
      t.text :number, comment: "A numeric or semi-numeric label for the shelf for sorting purposes"
      t.text :label, comment: "Any label that might be applied to a shelf; this may change over time"
      t.text :depth, null: false, default: "Single", comment: "Whether the shelf is a single bottle deep or multiple"
      t.text :notes, comment: "Any other descriptive information about the shelf"

      t.timestamps
    end

    add_index :shelves, [ :shelveable_type, :shelveable_id ]
    add_check_constraint :shelves,
      "shelveable_type IN ('Cellar', 'Bay')",
      name: "chk_shelves_shelveable_type"
    add_check_constraint :shelves,
      "depth IN ('Single', 'Multiple')",
      name: "chk_shelves_depth"

    add_reference :bottles, :cellarable, polymorphic: true, type: :uuid, null: true, comment: "Where this bottle is cellared"
    add_check_constraint :bottles,
      "cellarable_type IS NULL OR cellarable_type IN ('Cellar', 'Bin', 'Shelf')",
      name: "chk_bottles_cellarable_type"
  end
end
