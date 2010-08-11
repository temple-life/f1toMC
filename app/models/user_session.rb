require 'uri'

class UserSession

  attr_accessor :church_code, :access_token, :api_url, :person_url, :first_name, :last_name
  cattr_accessor :fellowshipone_api_url
  
  def api_url
    @url ||= APP_CONFIG["fellowshipone_api_url"].gsub(/:church_code/, church_code)
  end
end