class CreateProposedChangesAndUserTrustEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :proposed_changes, id: :uuid, comment: "Proposed changes are pending edits or merge proposals for community-curated canonical data." do |t|
      t.text :target_type, null: false, comment: "The model type being changed"
      t.uuid :target_id, null: false, comment: "The record being changed"
      t.references :proposed_by_user, null: false, type: :uuid, foreign_key: { to_table: :users }, comment: "User who submitted the proposal"
      t.references :reviewed_by_user, type: :uuid, foreign_key: { to_table: :users }, comment: "User who reviewed the proposal"
      t.text :status, null: false, default: "Pending", comment: "Review status"
      t.text :action, null: false, comment: "What kind of proposal this is"
      t.jsonb :proposed_attributes, null: false, default: {}, comment: "Proposed attribute values"
      t.jsonb :original_attributes, null: false, default: {}, comment: "Canonical values when the proposal was submitted"
      t.jsonb :reviewer_attributes, comment: "Reviewer-edited values applied at approval"
      t.text :duplicate_of_type, comment: "Proposed canonical duplicate target type"
      t.uuid :duplicate_of_id, comment: "Proposed canonical duplicate target id"
      t.text :review_notes, comment: "Notes from reviewer"
      t.datetime :submitted_at, null: false, comment: "When the proposal was submitted"
      t.datetime :reviewed_at, comment: "When the proposal was reviewed"

      t.timestamps
    end

    add_index :proposed_changes, %i[target_type target_id]
    add_index :proposed_changes, %i[duplicate_of_type duplicate_of_id]
    add_check_constraint :proposed_changes, "status IN ('Pending', 'Approved', 'Rejected', 'Superseded', 'Merged', 'Needs More Info')", name: "proposed_changes_status_check"
    add_check_constraint :proposed_changes, "action IN ('Update', 'Merge')", name: "proposed_changes_action_check"

    create_table :user_trust_events, id: :uuid, comment: "User trust events track promotions and demotions between trust levels." do |t|
      t.references :user, null: false, type: :uuid, foreign_key: true, comment: "The user whose trust level changed"
      t.references :actor, null: false, type: :uuid, foreign_key: { to_table: :users }, comment: "The user who changed the trust level"
      t.text :from_trust_level, null: false, comment: "Trust level before the change"
      t.text :to_trust_level, null: false, comment: "Trust level after the change"
      t.text :action, null: false, comment: "Whether this event is a promotion or demotion"
      t.text :notes, comment: "Optional notes about why the change was made"
      t.datetime :dismissed_at, comment: "When the promoted user dismissed this event"

      t.timestamps
    end

    add_check_constraint :user_trust_events, "from_trust_level IN ('Basic', 'Trusted', 'Curator', 'System Administrator')", name: "user_trust_events_from_trust_level_check"
    add_check_constraint :user_trust_events, "to_trust_level IN ('Basic', 'Trusted', 'Curator', 'System Administrator')", name: "user_trust_events_to_trust_level_check"
    add_check_constraint :user_trust_events, "action IN ('Promotion', 'Demotion')", name: "user_trust_events_action_check"
  end
end
