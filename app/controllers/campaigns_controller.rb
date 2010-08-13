class CampaignsController < ApplicationController
  before_filter :require_user_session
  before_filter :load_account
  before_filter :load_hominid
  
  def index
    @current_list = @hominid.find_list_by_id params[:list_id]
    @current_page = params[:page] ? params[:page].to_i : 1
    @campaigns = []
    campaigns = @hominid.campaigns({:list_id => params[:list_id]},  @current_page - 1, 20)
    campaigns.each do |campaign|
      stats = @hominid.campaign_stats campaign['id']
      total_bounces = stats['hard_bounces'].to_i + stats['soft_bounces'].to_i
      @campaigns << {:id => campaign['id'], :title => campaign['title'], :send_time => campaign['send_time'], :emails_sent => stats['emails_sent'], :bounces => total_bounces, :spam => stats['abuse_reports'], :unsubscribes => stats['unsubscribes']}
    end
  end

  def show
    @current_list = @hominid.find_list_by_id params[:list_id]
    @campaigns = @hominid.campaigns({:list_id => params[:list_id]},  0, 20)
    @campaign = @campaigns.find { |campaign| campaign['id'] == params[:id] }
    @stats = @hominid.campaign_stats params[:id]
  end
  
  private
  
  def load_hominid
    @hominid = Hominid::Base.new({:api_key => @current_account.mailchimp_key})
  end

end
