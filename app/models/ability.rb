class Ability
  include CanCan::Ability

  def initialize(user = nil)
    user ||= User.new
    UserPermission.where(user_id: user).each do |x|
        if !x.permission.blank?
            can x.permission.operation.to_sym, eval(x.permission.module_name)
            # binding.pry
        end
    end



    # if user.superadmin?
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



