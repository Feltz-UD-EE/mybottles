class CreateWineClubs < ActiveRecord::Migration[8.0]
  def change
    create_table :wine_clubs, id: :uuid, comment: "Wine clubs are subscription memberships offered by wineries that include such features as discounts, free or reduced shipping, access to special wines, preferential treatment at the producer's tasting rooms, invitations to special events, etc. A given producer will typically offer several wine club tiers." do |t|
      t.references :producer, null: false, type: :uuid, foreign_key: { on_delete: :restrict }, comment: "The producer offering the wine club"
      t.text :tier, comment: "The tier title of the club membership - like gold, reserve, etc."
      t.integer :size, null: false, comment: "The number of bottles in each club order"
      t.text :schedule, null: false, comment: "How often and when wine is delivered"
      t.text :delivery_method, comment: "Whether the wine is shipped or held for pickup"
      t.text :payment_method, comment: "How the club membership is paid for (typically a pre-approved credit card)"
      t.decimal :discount, precision: 5, scale: 2, comment: "What discount the club order is processed at relative to list price"
      t.date :date_joined, comment: "When I joined the wine club"
      t.date :date_left, comment: "When I cancelled my wine club membership"
      t.text :member_id, comment: "An ID supplied by the producer"
      t.text :benefits, comment: "Any other benefits accruing to club members"

      t.timestamps
    end

    add_check_constraint :wine_clubs,
      "delivery_method IS NULL OR delivery_method IN ('Shipping', 'Pickup')",
      name: "chk_wine_clubs_delivery_method"
    add_check_constraint :wine_clubs,
      "discount IS NULL OR (discount >= 0 AND discount <= 100)",
      name: "chk_wine_clubs_discount_percentage"
  end
end
