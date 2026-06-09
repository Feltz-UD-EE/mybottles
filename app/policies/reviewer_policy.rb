class ReviewerPolicy < ApplicationPolicy
  def index?
    user&.reviewer?
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
end
