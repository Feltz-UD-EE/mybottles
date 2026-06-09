class CreateGeographyTables < ActiveRecord::Migration[8.0]
  def change
    create_table :countries, id: :uuid, comment: "Countries are just what they say they are - the top political bodies." do |t|
      t.text :name, null: false, comment: "The common name for the country"
      t.text :fullname, comment: "The full legal name of the country"
      t.text :iso2, null: false, comment: "The ISO-2 country code for the country"
      t.text :iso3, null: false, comment: "The ISO-3 country code for the country"
      t.text :notes, comment: "Other descriptive notes"

      t.timestamps
    end

    create_table :appellations, id: :uuid, comment: "An appellation is a legally defined, named region for wine production. The appellation system for wines was first pioneered in France. All wines either have an appellation, or as a default, a country. Appellations are often nested within each other." do |t|
      t.references :country, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, comment: "What country the appellation is in"
      t.text :name, null: false, comment: "The nametag or other label applied to the bin"
      t.text :degree, comment: "The legal category of appellations - many countries have two or more"
      t.references :parent, type: :uuid, foreign_key: { to_table: :appellations, on_delete: :restrict }, comment: "The parent appellation, if present"
      t.text :notes, comment: "Any other descriptive information about the appellation"
      t.boolean :auto_generated, default: false, null: false, comment: "Whether the information for this appellation was LLM-generated"

      t.timestamps
    end
  end
end
