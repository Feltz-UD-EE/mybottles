class AddInventoryAdjustmentDisposalMethod < ActiveRecord::Migration[8.0]
  DISPOSAL_METHODS = [ "Drink", "Gift", "Sale", "Spoiled", "Inventory Adjustment" ].freeze
  PREVIOUS_DISPOSAL_METHODS = [ "Drink", "Gift", "Sale", "Spoiled" ].freeze

  def up
    remove_check_constraint :bottles, name: "chk_bottles_disposal_method"
    add_check_constraint :bottles,
      "disposal_method IS NULL OR disposal_method IN (#{quoted_methods(DISPOSAL_METHODS)})",
      name: "chk_bottles_disposal_method"
  end

  def down
    remove_check_constraint :bottles, name: "chk_bottles_disposal_method"
    add_check_constraint :bottles,
      "disposal_method IS NULL OR disposal_method IN (#{quoted_methods(PREVIOUS_DISPOSAL_METHODS)})",
      name: "chk_bottles_disposal_method"
  end

  private

  def quoted_methods(methods)
    methods.map { |method| quote(method) }.join(", ")
  end
end
