class DeviseInvitableAddToUsers < ActiveRecord::Migration[8.0]
  def up
    change_table :users do |t|
      t.text :invitation_token, comment: "Token used for invitations"
      t.datetime :invitation_created_at, comment: "When an invitation was created"
      t.datetime :invitation_sent_at, comment: "When an invitation was sent"
      t.datetime :invitation_accepted_at, comment: "When an invitation was accepted"
      t.integer :invitation_limit
      t.references :invited_by, polymorphic: true, type: :uuid
      t.integer :invitations_count, default: 0
      t.index :invitation_token, unique: true # for invitable
      t.index :invited_by_id
    end
  end

  def down
    change_table :users do |t|
      t.remove_references :invited_by, polymorphic: true
      t.remove :invitations_count, :invitation_limit, :invitation_sent_at, :invitation_accepted_at, :invitation_token, :invitation_created_at
    end
  end
end
