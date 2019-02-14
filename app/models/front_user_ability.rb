class FrontUserAbility
  include CanCan::Ability

  Sequence.initial

  def initialize(front_user = nil)
    if front_user.blank?
      cannot :read, :all
      cannot :manage, :all
    else
      can :read, :all
      can :manage, :all
    end
  end
end



