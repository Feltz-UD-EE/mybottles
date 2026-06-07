class CreateWatchListEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :watch_list_entries, id: :uuid, comment: "Watch list entries are vintages, wines, or general information about wines I want to purchase in the future." do |t|
      t.references :watchable, type: :uuid, polymorphic: true, index: true, comment: "The wine or vintage to watch for"
      t.text :description, null: false, comment: "The motivation or justification for looking for this wine"
      t.text :quantity, comment: "How much to purchase"
      t.text :caveat, comment: "Description of why not to buy the wine if it is available - too expensive, bad vintage, etc."
      t.text :notes, comment: "Any additional information about this entry, including exclusive retailers, date of availability, etc."
      t.datetime :deleted_at, comment: "When this watch list entry was soft-deleted"

      t.timestamps
    end
  end
end
