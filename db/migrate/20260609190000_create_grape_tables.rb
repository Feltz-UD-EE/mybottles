class CreateGrapeTables < ActiveRecord::Migration[8.0]
  COMMUNITY_COLUMNS = lambda do |t, table_name|
    t.text :approval_status, null: false, default: "Approved", comment: "Review status for this record"
    t.references :created_by_user, type: :uuid, foreign_key: { to_table: :users }, index: true, comment: "User who first created this record"
    t.references :approved_by_user, type: :uuid, foreign_key: { to_table: :users }, index: true, comment: "User who approved this record"
    t.datetime :approved_at, comment: "When this record was approved"
    t.references :rejected_by_user, type: :uuid, foreign_key: { to_table: :users }, index: true, comment: "User who rejected this record"
    t.datetime :rejected_at, comment: "When this record was rejected"
    t.references :merged_into, type: :uuid, foreign_key: { to_table: table_name }, index: true, comment: "Canonical record this duplicate was merged into"
  end

  def change
    create_table :grapes, id: :uuid, comment: "Grapes are botanical wine-making grape varieties or recognized wine-making grape cultivars." do |t|
      t.text :name, null: false, comment: "The common display name of the grape"
      t.text :notes, comment: "Notes about the grape"
      COMMUNITY_COLUMNS.call(t, :grapes)
      t.timestamps
    end

    add_check_constraint :grapes, "approval_status IN ('Pending', 'Approved', 'Rejected', 'Merged')", name: "grapes_approval_status_check"
    add_index :grapes, :name

    create_table :grape_synonyms, id: :uuid, comment: "Grape synonyms record that two grape records are known synonyms." do |t|
      t.references :grape, null: false, type: :uuid, foreign_key: true, index: true, comment: "One grape in the synonym pair"
      t.references :synonym_grape, null: false, type: :uuid, foreign_key: { to_table: :grapes }, index: true, comment: "The other grape in the synonym pair"
      t.text :notes, comment: "Notes about the synonym relationship"
      COMMUNITY_COLUMNS.call(t, :grape_synonyms)
      t.timestamps
    end

    add_check_constraint :grape_synonyms, "approval_status IN ('Pending', 'Approved', 'Rejected', 'Merged')", name: "grape_synonyms_approval_status_check"
    add_check_constraint :grape_synonyms, "grape_id <> synonym_grape_id", name: "grape_synonyms_distinct_grapes_check"
    add_index :grape_synonyms,
      "LEAST(grape_id, synonym_grape_id), GREATEST(grape_id, synonym_grape_id)",
      unique: true,
      where: "approval_status <> 'Merged'",
      name: "index_grape_synonyms_on_unordered_pair"

    create_table :appellation_grapes, id: :uuid, comment: "Appellation grapes record grapes that are permitted in an appellation." do |t|
      t.references :appellation, null: false, type: :uuid, foreign_key: true, index: true, comment: "The appellation where this grape is permitted"
      t.references :grape, null: false, type: :uuid, foreign_key: true, index: true, comment: "The permitted grape"
      t.text :notes, comment: "Notes about this grape in this appellation"
      COMMUNITY_COLUMNS.call(t, :appellation_grapes)
      t.timestamps
    end

    add_check_constraint :appellation_grapes, "approval_status IN ('Pending', 'Approved', 'Rejected', 'Merged')", name: "appellation_grapes_approval_status_check"
    add_index :appellation_grapes,
      [ :appellation_id, :grape_id ],
      unique: true,
      where: "approval_status <> 'Merged'",
      name: "index_appellation_grapes_on_appellation_and_grape"
  end
end
