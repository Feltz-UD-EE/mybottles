# frozen_string_literal: true

# Migration responsible for creating a table with activities
class CreateActivities < ActiveRecord::Migration[8.0]
  def self.up
    create_table :activities, id: :uuid do |t|
      t.belongs_to :trackable, polymorphic: true, type: :uuid
      t.belongs_to :owner, polymorphic: true, type: :uuid
      t.string :key
      t.text :parameters
      t.belongs_to :recipient, polymorphic: true, type: :uuid

      t.timestamps
    end
  end

  # Drop table
  def self.down
    drop_table :activities
  end
end
