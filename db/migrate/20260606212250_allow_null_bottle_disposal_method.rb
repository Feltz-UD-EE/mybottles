class AllowNullBottleDisposalMethod < ActiveRecord::Migration[8.0]
  def up
    remove_check_constraint :bottles, name: "chk_bottles_disposal_method"
    change_column_null :bottles, :disposal_method, true
    add_check_constraint :bottles,
      "disposal_method IS NULL OR disposal_method IN ('Drink', 'Gift', 'Sale', 'Spoiled')",
      name: "chk_bottles_disposal_method"
  end

  def down
    remove_check_constraint :bottles, name: "chk_bottles_disposal_method"
    change_column_null :bottles, :disposal_method, false
    add_check_constraint :bottles,
      "disposal_method IN ('Drink', 'Gift', 'Sale', 'Spoiled')",
      name: "chk_bottles_disposal_method"
  end
end
