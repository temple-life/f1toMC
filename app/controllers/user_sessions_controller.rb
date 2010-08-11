class UserSessionsController < ApplicationController
  layout 'public'
  
  def new
  end

  def create
    if params[:church_code].empty?
      flash[:error] = "Church code is required. Please enter your church code before proceeding."
      render :new
    else
      @user_session = UserSession.new
      @user_session.church_code = params[:church_code].downcase
      
      site = @user_session.api_url
      oauth_callback = user_sessions_callback_url
      key = APP_CONFIG["fellowshipone_api_key"]
      secret = APP_CONFIG["fellowshipone_api_secret"]
       
      @consumer = OAuth::Consumer.new(key, secret, {
        :site => site + "/",
        :request_token_url => "#{site}/Tokens/RequestToken",
        :authorize_url => "#{site}/PortalUser/Login",
        :access_token_url => "#{site}/Tokens/AccessToken",
        :oauth_callback => oauth_callback
      })

      begin
        @request_token = @consumer.get_request_token({:oauth_callback => oauth_callback})
      
        if @request_token
          session[:request_token] = @request_token

          store_user_session @user_session
      
          redirect_to @request_token.authorize_url + "&oauth_callback=#{oauth_callback}"
        end
      rescue OAuth::Unauthorized => unauthorized
        flash[:error] = "Sign in attempt failed."
        redirect_to signin_path
      end
    end
  end
  
  def callback
    @user_session = retrieve_user_session
    
    @request_token = session[:request_token]
    @access_token = @request_token.get_access_token
    
    # response = @request_token.consumer.token_request(@request_token.consumer.http_method,  @request_token.consumer.access_token_url, @request_token, {})
    # @access_token = OAuth::AccessToken.from_hash( @request_token.consumer, response)
    
    @user_session.access_token = @access_token
    
    store_user_session @user_session
    
    # don't need the request token anymore
    remove_request_token
    
    Account.find_or_create_by_church_code @user_session.church_code
    
    redirect_to root_path
  end
  
  def destroy
    remove_request_token
    session[:user_session] = nil unless session[:user_session].nil?

    redirect_to signin_url
  end
  
  private
  
  def remove_request_token
    session[:request_token] = nil unless session[:request_token].nil?
  end

end
