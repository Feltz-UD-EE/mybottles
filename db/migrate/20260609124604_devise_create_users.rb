# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid, comment: "Users are people who can sign in, manage private cellar data, and participate in trust-based community data workflows." do |t|
      ## Database authenticatable
      t.text :email, null: false, default: "", comment: "The user's email address"
      t.text :encrypted_password, null: false, default: "", comment: "Devise encrypted password"

      t.text :trust_level, null: false, default: "Basic", comment: "The user's trust level"
      t.text :name, comment: "The user's display name"
      t.text :theme_preference, null: false, default: "System", comment: "The user's preferred visual theme"
      t.boolean :print_labels_by_default, null: false, default: false, comment: "Whether bottle creation should print labels by default"

      ## Recoverable
      t.text :reset_password_token, comment: "Token used for password reset"
      t.datetime :reset_password_sent_at, comment: "When password reset instructions were sent"

      ## Rememberable
      t.datetime :remember_created_at, comment: "When the remember-me session was created"

      ## Trackable
      t.integer :sign_in_count, default: 0, null: false, comment: "Number of sign-ins"
      t.datetime :current_sign_in_at, comment: "Current sign-in timestamp"
      t.datetime :last_sign_in_at, comment: "Previous sign-in timestamp"
      t.text :current_sign_in_ip, comment: "Current sign-in IP"
      t.text :last_sign_in_ip, comment: "Previous sign-in IP"

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_check_constraint :users, "trust_level IN ('Basic', 'Trusted', 'Curator', 'System Administrator')", name: "users_trust_level_check"
    add_check_constraint :users, "theme_preference IN ('Light', 'Dark', 'System')", name: "users_theme_preference_check"
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
