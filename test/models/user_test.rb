require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "system administrator password comes from environment variable" do
    with_system_admin_password("environment-password") do
      assert_equal "environment-password", User.system_administrator_password
    end
  end

  test "system administrator bootstraps with environment password" do
    User.where(email: User::SYSTEM_ADMIN_EMAIL).delete_all

    with_system_admin_password("environment-password") do
      user = User.bootstrap_system_administrator!

      assert_equal User::SYSTEM_ADMIN_EMAIL, user.email
      assert_equal "System Administrator", user.trust_level
      assert user.valid_password?("environment-password")
    end
  end

  test "system administrator password falls back in development and test" do
    with_system_admin_password(nil) do
      assert_equal User::DEVELOPMENT_SYSTEM_ADMIN_PASSWORD, User.system_administrator_password
    end
  end

  private

  def with_system_admin_password(password)
    previous_password = ENV[User::SYSTEM_ADMIN_PASSWORD_ENV]

    if password.nil?
      ENV.delete(User::SYSTEM_ADMIN_PASSWORD_ENV)
    else
      ENV[User::SYSTEM_ADMIN_PASSWORD_ENV] = password
    end

    yield
  ensure
    if previous_password.nil?
      ENV.delete(User::SYSTEM_ADMIN_PASSWORD_ENV)
    else
      ENV[User::SYSTEM_ADMIN_PASSWORD_ENV] = previous_password
    end
  end
end
