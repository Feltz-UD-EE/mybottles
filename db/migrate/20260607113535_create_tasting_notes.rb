class CreateTastingNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :tasting_notes, id: :uuid, comment: "Tasting Notes are personal notes about tasting wine - from a particular bottle, or from a representative wine & vintage at a winery or retailer." do |t|
      t.references :tasteable, null: false, type: :uuid, polymorphic: true, index: true, comment: "The bottle or vintage being tasted"
      t.date :date, null: false, comment: "The date the tasting took place"
      t.text :setting, comment: "The setting where the tasting took place"
      t.text :temperature, comment: "The temperature of the wine"
      t.text :pairing, comment: "Any accompanying food"
      t.text :color, comment: "The color of the wine"
      t.text :nose, comment: "The aromatic elements of the wine"
      t.text :palate, comment: "The taste elements of the wine"
      t.text :overall, comment: "The overall impression of the wine"
      t.decimal :score, precision: 10, scale: 1, comment: "The personal numeric score given to the wine (optional)"
      t.boolean :buy, comment: "Should I buy this wine (or buy it again if the tasting note refers to a bottle)"

      t.timestamps
    end
  end
end
