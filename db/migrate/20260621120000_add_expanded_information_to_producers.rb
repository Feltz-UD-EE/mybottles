class AddExpandedInformationToProducers < ActiveRecord::Migration[8.0]
  def change
    add_column :producers, :notes, :text, comment: "General free-form notes about the producer"
    add_column :producers, :tasting_room, :text, comment: "Free-form notes about the producer tasting room"
    add_column :producers, :club_options, :text, comment: "Free-form notes about producer wine club options"
  end
end
