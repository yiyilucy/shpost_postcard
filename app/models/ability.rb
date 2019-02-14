class Ability
  include CanCan::Ability

  Sequence.initial

  def initialize(user = nil)
    if user.blank?
      cannot :read, :all
      cannot :manage, :all
    elsif user.username.eql? 'superadmin'
      can :read, :all
      can :manage, :all
    else
      UserPermission.where(user_id: user).each do |x|
        if !x.permission.blank?
          JSON.parse(x.permission.operation).each do |o|
            can o.to_sym, eval(x.permission.module_name)
          end
        end
      end
      can :update, User, id: user.id
      can :manage, Commodity
    end
  end
end



