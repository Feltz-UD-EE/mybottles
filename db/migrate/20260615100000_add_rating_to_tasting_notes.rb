class AddRatingToTastingNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :tasting_notes, :rating, :decimal, precision: 3, scale: 2, null: false, default: "0.0",
      comment: "Structured personal rating from zero to five in quarter-point increments"
    add_check_constraint :tasting_notes,
      "rating >= 0 AND rating <= 5",
      name: "chk_tasting_notes_rating_range"
    add_check_constraint :tasting_notes,
      "(rating * 100)::integer % 25 = 0",
      name: "chk_tasting_notes_rating_quarter_increment"
  end
end
