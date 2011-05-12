class ListsController < ApplicationController
  before_filter :require_user_session
  before_filter :load_account
  before_filter :load_hominid
  
  def index
    @syncd_lists = find_syncd_lists
  end

  def show
    @syncd_lists = find_syncd_lists
    @current_list = @syncd_lists.find { |list| list['id'] == params[:id] }
    
    logger.debug @current_list.to_yaml
    
    @list_members = []
    @current_page = params[:page] ? params[:page].to_i : 1
    members = @hominid.list_members(params[:id], "subscribed", @current_list['date_created'], @current_page - 1, 20)
    
    info = @hominid.list_member_info(params[:id], members['data'].map{|member| member['email']})
    
    @list_members = {
      :total_records => info['total'],
      :data => info['data']
    }
  end
  
  private
  
  def load_hominid
    @hominid = Hominid::API.new(@current_account.mailchimp_key)
  end

  def find_syncd_lists
    lists = @hominid.lists
    saved_lists = @current_account.synchronize.all
    
    syncd_lists = lists['data'].find_all do |list|
      saved_lists.find { |sl| sl.mailchimp_list_id == list['id'] }
    end
    
    syncd_lists
  end

end
