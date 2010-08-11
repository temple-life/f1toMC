class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  helper_method :current_user_session
  
  before_filter :put_api_url_on_user_session
  
  private
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = retrieve_user_session
  end
  
  def require_user_session
    unless current_user_session
      store_location
      redirect_to signin_path
      return false
    end
  end
  
  def put_api_url_on_user_session
    if current_user_session
      UserSession.fellowshipone_api_url = current_user_session.api_url
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def stored_location_or_default(default)
    session[:return_to] || default
  end
  
  def store_user_session(user_session = nil)
    session[:user_session] = user_session
  end
  
  def retrieve_user_session
    session[:user_session]
  end
  
  def load_account
    @current_account ||= Account.where({:church_code => current_user_session.church_code}).first
  end
  
  protected
  
  def render_optional_error_file(status_code)
    status = interpret_status(status_code)
    
    if ["404", "422", "500"].include?(status)
      render :template => "/errors/#{status[0,3]}", :status => status, :layout => 'errors'
    else
      render :template => "/errors/unknown", :status => status, :layout => 'errors'
    end
  end
  
end
