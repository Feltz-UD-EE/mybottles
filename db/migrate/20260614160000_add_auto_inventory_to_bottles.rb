class AddAutoInventoryToBottles < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :next_auto_inventory_number, :integer, null: false, default: 1,
      comment: "Next sequential number to use when generating a bottle auto-inventory code"
    add_column :bottles, :auto_inventory, :text,
      comment: "System-generated bottle inventory code used when no personal inventory code is provided"
    add_index :bottles, [ :user_id, :auto_inventory ],
      unique: true,
      where: "auto_inventory IS NOT NULL",
      name: "index_bottles_on_user_id_and_auto_inventory"

    backfill_auto_inventory
  end

  def down
    remove_index :bottles, name: "index_bottles_on_user_id_and_auto_inventory"
    remove_column :bottles, :auto_inventory
    remove_column :users, :next_auto_inventory_number
  end

  private

  def backfill_auto_inventory
    select_values("SELECT id FROM users ORDER BY created_at, id").each do |user_id|
      next_number = 1

      select_values(<<~SQL.squish).each do |bottle_id|
        SELECT id
        FROM bottles
        WHERE user_id = #{quote(user_id)}
          AND (personal_inventory IS NULL OR btrim(personal_inventory) = '')
          AND auto_inventory IS NULL
        ORDER BY created_at, id
      SQL
        execute <<~SQL.squish
          UPDATE bottles
          SET auto_inventory = #{quote(auto_inventory_code(next_number))}
          WHERE id = #{quote(bottle_id)}
        SQL
        next_number += 1
      end

      execute <<~SQL.squish
        UPDATE users
        SET next_auto_inventory_number = #{next_number}
        WHERE id = #{quote(user_id)}
      SQL
    end
  end

  def auto_inventory_code(number)
    number.to_i.to_s(36).upcase.rjust(6, "0")
  end
end
