# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: 'pwd12345', name: 'superadmin')

permission1 = Permission.create(module_name: 'User', operation: 'read', is_show: false)
permission2 = Permission.create(module_name: 'User', operation: 'create', is_show: false)
permission3 = Permission.create(module_name: 'User', operation: 'update', is_show: false)
permission4 = Permission.create(module_name: 'User', operation: 'destroy', is_show: false)
permission5 = Permission.create(module_name: 'User', operation: 'permission', is_show: false)
permission6 = Permission.create(module_name: 'Permission', operation: 'read', is_show: false)
permission7 = Permission.create(module_name: 'Permission', operation: 'do_permission', is_show: false)
permission8 = Permission.create(module_name: 'UserLog', operation: 'read')

permission9 = Permission.create(module_name: 'User', operation: 'reset_pwd', is_show: false)

UserPermission1 = UserPermission.create(user_id: superadmin.id, permission_id: permission1.id)
UserPermission2 = UserPermission.create(user_id: superadmin.id, permission_id: permission2.id)
UserPermission3 = UserPermission.create(user_id: superadmin.id, permission_id: permission3.id)
UserPermission4 = UserPermission.create(user_id: superadmin.id, permission_id: permission4.id)
UserPermission5 = UserPermission.create(user_id: superadmin.id, permission_id: permission5.id)
UserPermission6 = UserPermission.create(user_id: superadmin.id, permission_id: permission6.id)
UserPermission7 = UserPermission.create(user_id: superadmin.id, permission_id: permission7.id)
UserPermission8 = UserPermission.create(user_id: superadmin.id, permission_id: permission8.id)
UserPermission9 = UserPermission.create(user_id: superadmin.id, permission_id: permission9.id)
