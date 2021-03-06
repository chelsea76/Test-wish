class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found


  #before_action :check_user_signin
  alias_method :logged_in?, :user_signed_in?
  alias_method :signed_in?, :user_signed_in?

  layout :resolve_layout

  helper_method :logged_in?

  def record_not_found
    redirect_to root_path
  end

  def ensure_signup_complete
    return if action_name == 'finish_signup' # ensure we don't go into an infinite loop
    return redirect_to(finish_signup_path current_user) if current_user && !current_user.email_verified?
  end

  def resolve_layout
    request.xhr? ? false : 'application'
  end

  def check_user_signin
    redirect_to root_path if (!request.xhr? && current_user.nil? && (params[:action] != 'login'))
  end
end
