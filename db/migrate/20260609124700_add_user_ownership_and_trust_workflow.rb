require "bcrypt"

class AddUserOwnershipAndTrustWorkflow < ActiveRecord::Migration[8.0]
  PRIVATE_TABLES = %i[
    bottles
    cellars
    bins
    bays
    shelves
    tasting_notes
    wine_clubs
    watch_list_entries
  ].freeze

  COMMUNITY_TABLES = %i[
    producers
    wines
    vintages
  ].freeze

  def up
    admin_id = ensure_system_administrator

    PRIVATE_TABLES.each do |table_name|
      add_reference table_name, :user, type: :uuid, foreign_key: true, index: true, comment: "The user who owns this record"
      execute "UPDATE #{table_name} SET user_id = #{quote(admin_id)}"
      change_column_null table_name, :user_id, false
    end

    COMMUNITY_TABLES.each do |table_name|
      add_column table_name, :approval_status, :text, null: false, default: "Approved", comment: "Review status for this record"
      add_reference table_name, :created_by_user, type: :uuid, foreign_key: { to_table: :users }, index: true, comment: "User who first created this record"
      add_reference table_name, :approved_by_user, type: :uuid, foreign_key: { to_table: :users }, index: true, comment: "User who approved this record"
      add_column table_name, :approved_at, :datetime, comment: "When this record was approved"
      add_reference table_name, :rejected_by_user, type: :uuid, foreign_key: { to_table: :users }, index: true, comment: "User who rejected this record"
      add_column table_name, :rejected_at, :datetime, comment: "When this record was rejected"
      add_reference table_name, :merged_into, type: :uuid, foreign_key: { to_table: table_name }, index: true, comment: "Canonical record this duplicate was merged into"
      add_check_constraint table_name, "approval_status IN ('Pending', 'Approved', 'Rejected', 'Merged')", name: "#{table_name}_approval_status_check"
      execute "UPDATE #{table_name} SET created_by_user_id = #{quote(admin_id)}, approved_by_user_id = #{quote(admin_id)}, approved_at = NOW()"
    end
  end

  def down
    COMMUNITY_TABLES.reverse_each do |table_name|
      remove_check_constraint table_name, name: "#{table_name}_approval_status_check"
      remove_reference table_name, :merged_into, foreign_key: { to_table: table_name }
      remove_column table_name, :rejected_at
      remove_reference table_name, :rejected_by_user, foreign_key: { to_table: :users }
      remove_column table_name, :approved_at
      remove_reference table_name, :approved_by_user, foreign_key: { to_table: :users }
      remove_reference table_name, :created_by_user, foreign_key: { to_table: :users }
      remove_column table_name, :approval_status
    end

    PRIVATE_TABLES.reverse_each do |table_name|
      remove_reference table_name, :user, foreign_key: true
    end
  end

  private

  def ensure_system_administrator
    email = "johncfeltz@gmail.com"
    existing_id = select_value("SELECT id FROM users WHERE email = #{quote(email)}")
    return existing_id.tap { |id| execute "UPDATE users SET trust_level = 'System Administrator' WHERE id = #{quote(id)}" } if existing_id.present?

    password = system_administrator_password

    id = select_value("SELECT gen_random_uuid()")
    encrypted_password = BCrypt::Password.create(password)
    now = quote(Time.current)
    execute <<~SQL.squish
      INSERT INTO users (id, email, encrypted_password, trust_level, theme_preference, print_labels_by_default, created_at, updated_at)
      VALUES (#{quote(id)}, #{quote(email)}, #{quote(encrypted_password)}, 'System Administrator', 'System', false, #{now}, #{now})
    SQL
    id
  end

  def system_administrator_password
    password = ENV["MYBOTTLES_SYSTEM_ADMIN_PASSWORD"]
    return password if password.present?
    return "Bottle4Bottle" if Rails.env.development? || Rails.env.test?

    raise "MYBOTTLES_SYSTEM_ADMIN_PASSWORD must be set"
  end
end
