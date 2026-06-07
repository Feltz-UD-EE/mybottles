class AllowSameDayBottleDisposal < ActiveRecord::Migration[8.0]
  def up
    remove_check_constraint :bottles, name: "chk_bottles_disposal_date_after_purchase_date"
    add_check_constraint :bottles,
      "purchase_date IS NULL OR disposal_date IS NULL OR disposal_date >= purchase_date",
      name: "chk_bottles_disposal_date_after_purchase_date"
  end

  def down
    remove_check_constraint :bottles, name: "chk_bottles_disposal_date_after_purchase_date"
    add_check_constraint :bottles,
      "purchase_date IS NULL OR disposal_date IS NULL OR disposal_date > purchase_date",
      name: "chk_bottles_disposal_date_after_purchase_date"
  end
end
