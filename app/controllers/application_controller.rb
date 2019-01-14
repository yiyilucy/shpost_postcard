class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  rescue_from Exception, with: :get_errors if Rails.env.production?

  rescue_from CanCan::AccessDenied, with: :access_denied if Rails.env.production?

  protect_from_forgery with: :exception

  before_filter :configure_charsets
  before_filter :authenticate_user!

  def self.user_logs_filter *args
    after_filter args.first.select{|k,v| k == :only || k == :expert} do |controller|
      save_user_log args.first.reject{|k,v| k == :only || k == :expert}
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def configure_charsets
    headers["Content-Type"]="text/html;charset=utf-8"
  end

  def save_user_log *args
    object = eval("@#{args.first[:object].to_s}")
    
    object ||= eval("@#{controller_name.singularize}")

    operation = eval("@#{args.first[:operation].to_s}")
    
    symbol = args.first[:symbol]
    # binding.pry
    @user_log = UserLog.new(user: current_user, operation: operation)
     
    if object
      if object.errors.blank?
        @user_log.object_class = object.class.to_s
        @user_log.object_primary_key = object.id
          
        if symbol
          if object[symbol.to_sym]
            @user_log.object_symbol = object[symbol.to_sym]
          elsif !eval("@#{args.first[:symbol].to_s}").blank?
            @user_log.object_symbol = eval("@#{args.first[:symbol].to_s}")
          else
            @user_log.object_symbol = object.send(symbol.to_sym)
          end
        end
                      
        @user_log.save
      end
    else
      @user_log.object_class = args.first[:object].to_s.capitalize!
      @user_log.object_symbol = eval("@#{args.first[:symbol].to_s}")

      @user_log.save
    end
  end

  def set_autocom_update(objid)
    @cname = Commodity.find(objid.commodity_id).all_name
  end

     
  private
  def access_denied exception
    @error_title = I18n.t 'errors.access_deny.title', default: 'Access Denied!'
    @error_message = I18n.t 'errors.access_deny.message', default: 'The user has no permission to vist this page'
    render template: '/errors/error_page',layout: false
  end

  def get_errors exception
    # Rails.logger.error(exception)
    Rails.logger.error("#{exception.class.name} #{exception.message}")
    exception.backtrace.each{|x| Rails.logger.error(x)}
    
    @error_title = I18n.t 'errors.get_errors.title', default: 'Get An Error!'
    @error_message = I18n.t 'errors.get_errors.message', default: 'The operation you did get an error'
    render :template => '/errors/error_page',layout: false
  end

  
end
