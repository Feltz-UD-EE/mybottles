class ExpandAutoInventoryCodesToSixCharacters < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE bottles
      SET auto_inventory = lpad(auto_inventory, 6, '0')
      WHERE auto_inventory IS NOT NULL
        AND length(auto_inventory) < 6
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE bottles
      SET auto_inventory = ltrim(auto_inventory, '0')
      WHERE auto_inventory IS NOT NULL
        AND auto_inventory ~ '^[0-9]+$'
    SQL

    execute <<~SQL.squish
      UPDATE bottles
      SET auto_inventory = '0'
      WHERE auto_inventory = ''
    SQL
  end
end
