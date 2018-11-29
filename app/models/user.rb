class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :user_logs
  has_many :user_permissions, dependent: :destroy

  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable, :lockable

  validates_presence_of :username, :name, :message => '不能为空字符'#,

  validates_uniqueness_of :username, :message => '该用户已存在'

  validate :password_complexity

 
  def email_required?
    false
  end

  def password_required?
    encrypted_password.blank? ? true : false
  end

  def password_complexity
    if password.present?
       if !password.match(/^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,128}$/) 
         errors.add :password, "密码需同时包含英文字母和数字"
       end
    end
  end

end
