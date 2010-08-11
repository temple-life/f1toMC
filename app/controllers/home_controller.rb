class HomeController < ApplicationController
  before_filter :require_user_session
  before_filter :load_account
  
  def index
  end

end
