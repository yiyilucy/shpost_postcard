class Ability
  include CanCan::Ability

  Sequence.initial
  
  def initialize(user = nil)
    user ||= User.new
    UserPermission.where(user_id: user).each do |x|
        if !x.permission.blank?
            JSON.parse(x.permission.operation).each do |o|
                can o.to_sym, eval(x.permission.module_name)
            end
            # binding.pry
        end
    end


    can :update, User, id: user.id
    # if user.superadmin?
        can :manage, Commodity
    # end
    #     can :manage, User
    #     can :manage, UserLog
    #     can :manage, Role
    #     can :role, :unitadmin
    #     can :role, :user

    #     # cannot :role, :superadmin
    #     # cannot [:role, :create, :destroy, :update], User, role: 'superadmin'
    #     # can :update, User, id: user.id

        
    # elsif user.unitadmin?
    #     can :read, UserLog, user: {user_id: user.id}
    #     can :destroy, UserLog, operation: '订单导入'

    #     can :manage, User

    #     can :manage, Role
    #     cannot :role, User, role: 'superadmin'
    #     can :role, :unitadmin
    #     can :role, :user
        
    #     cannot [:create, :destroy, :update], User, role: ['unitadmin', 'superadmin']
    #     can :update, User, id: user.id
        
    # elsif user.user?
    #     can :update, User, id: user.id
    #     can :read, UserLog, user: {id: user.id}    
    # else
    #     cannot :manage, :all
    #     cannot :read, User
        
    # end


    end
end



