class SystemAdministratorPolicy < ApplicationPolicy
  def index?
    user&.system_administrator?
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end
end
