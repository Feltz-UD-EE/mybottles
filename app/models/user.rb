class User < ApplicationRecord
  TRUST_LEVELS = [ "Basic", "Trusted", "Curator", "System Administrator" ].freeze
  THEME_PREFERENCES = [ "Light", "Dark", "System" ].freeze
  SYSTEM_ADMIN_EMAIL = "johncfeltz@gmail.com"
  SYSTEM_ADMIN_PASSWORD_ENV = "MYBOTTLES_SYSTEM_ADMIN_PASSWORD"
  DEVELOPMENT_SYSTEM_ADMIN_PASSWORD = "Bottle4Bottle"

  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  has_many :proposed_changes, foreign_key: :proposed_by_user_id, dependent: :restrict_with_error
  has_many :reviewed_proposed_changes, class_name: "ProposedChange", foreign_key: :reviewed_by_user_id, dependent: :nullify
  has_many :user_trust_events, dependent: :restrict_with_error
  has_many :trust_events_performed, class_name: "UserTrustEvent", foreign_key: :actor_id, dependent: :restrict_with_error

  validates :trust_level, inclusion: { in: TRUST_LEVELS }
  validates :theme_preference, inclusion: { in: THEME_PREFERENCES }

  before_validation :assign_defaults

  scope :basic, -> { where(trust_level: "Basic") }
  scope :trusted, -> { where(trust_level: "Trusted") }
  scope :curators, -> { where(trust_level: "Curator") }
  scope :system_administrators, -> { where(trust_level: "System Administrator") }

  def self.system_administrator
    find_by(email: SYSTEM_ADMIN_EMAIL) || bootstrap_system_administrator!
  end

  def self.bootstrap_system_administrator!(reset_password: false)
    password = system_administrator_password

    user = find_or_initialize_by(email: SYSTEM_ADMIN_EMAIL)
    user.trust_level = "System Administrator"
    user.name ||= "System Administrator"
    user.theme_preference ||= "System"
    user.print_labels_by_default = false if user.print_labels_by_default.nil?
    user.password = password if user.new_record? || reset_password
    user.password_confirmation = password if user.new_record? || reset_password
    user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    user.save!
    user
  end

  def self.system_administrator_password
    password = ENV[SYSTEM_ADMIN_PASSWORD_ENV].presence
    return password if password.present?
    return DEVELOPMENT_SYSTEM_ADMIN_PASSWORD if Rails.env.development? || Rails.env.test?

    raise "#{SYSTEM_ADMIN_PASSWORD_ENV} must be set"
  end

  def basic?
    trust_level == "Basic"
  end

  def trusted?
    trust_level == "Trusted"
  end

  def curator?
    trust_level == "Curator"
  end

  def system_administrator?
    trust_level == "System Administrator"
  end

  def reviewer?
    curator? || system_administrator?
  end

  def can_administer_users?
    system_administrator?
  end

  def promote!(actor)
    change_trust_level!(actor, next_trust_level, "Promotion")
  end

  def demote!(actor)
    change_trust_level!(actor, previous_trust_level, "Demotion")
  end

  def next_trust_level
    TRUST_LEVELS[TRUST_LEVELS.index(trust_level).to_i + 1]
  end

  def previous_trust_level
    TRUST_LEVELS[TRUST_LEVELS.index(trust_level).to_i - 1] unless basic?
  end

  private

  def assign_defaults
    self.trust_level ||= "Basic"
    self.theme_preference ||= "System"
    self.print_labels_by_default = false if print_labels_by_default.nil?
    self.next_auto_inventory_number ||= 1
  end

  def change_trust_level!(actor, target_level, action)
    raise ArgumentError, "trust level cannot be changed" if target_level.blank?
    raise ArgumentError, "system administrators cannot be demoted" if system_administrator? && action == "Demotion"

    transaction do
      from = trust_level
      update!(trust_level: target_level)
      UserTrustEvent.create!(
        user: self,
        actor: actor,
        from_trust_level: from,
        to_trust_level: target_level,
        action: action
      )
    end
  end
end
