class SynchronizeController < ApplicationController
  before_filter :require_user_session
  before_filter :load_account
  
  def step_1
    attribute_groups_url = "#{current_user_session.api_url}people/AttributeGroups.json"
    raw = current_user_session.access_token.get(attribute_groups_url)
    decoded_json = ActiveSupport::JSON.decode(raw.body)
    @attribute_groups = []
    decoded_json['attributeGroups']['attributeGroup'].each do |attribute_group|
      @attribute_groups << AttributeGroup.new(attribute_group)
    end
    
    store_attribute_groups @attribute_groups
    
    @default_attributes = []
    
    if params[:search] and params[:attribute_group_id] and params[:person_attribute_id]
      @people = []
      group = find_attribute_group(params[:attribute_group_id].to_i)
      @default_attributes = group.person_attributes
      
      # perform the search
      search_url = "#{current_user_session.api_url}people/Search.json?attribute=#{params[:person_attribute_id]}&include=communications"
      search_raw = current_user_session.access_token.get(search_url)
      search_json = ActiveSupport::JSON.decode(search_raw.body)

      unless search_json.nil?
        unless search_json['results']['person'].nil?
          search_json['results']['person'].each do |person|
            new_person = Person.new(person)
            @people << new_person unless new_person.email.blank?
          end
        end
      end
    end
  end
  
  def save_step_1
    # save sync to session for step_2
    flash[:emails] = params[:emails]
    
    store_attribute_groups nil
    
    redirect_to synchronize_new_step_2_path
  end

  def step_2
    # retrieve sync from session
    hominid = Hominid::Base.new({:api_key => @current_account.mailchimp_key})
    @lists = hominid.lists
    
    @lists.each do |list|
      logger.debug "[DEBUG] #{list.inspect}"
    end
  end
  
  def create
    # write to mailchimp api
    # write sync record to db
    redirect_to home_path
  end
  
  def get_attributes
    group = find_attribute_group(params[:attribute_group_id].to_i)
    
    render :partial => "options_for_attributes", :locals => { :person_attributes => group.person_attributes }
  end
  
  private
  
  def store_attribute_groups(attribute_groups)
    session[:attribute_groups] = attribute_groups
  end
  
  def retrieve_attribute_groups
    session[:attribute_groups]
  end
  
  def find_attribute_group(group_id)
    @attribute_groups = retrieve_attribute_groups
    @attribute_groups.find{ |attribute_group| attribute_group.id == group_id }
  end

end
