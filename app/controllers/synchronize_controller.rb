class SynchronizeController < ApplicationController
  before_filter :require_user_session
  before_filter :load_account
  
  def step_1
    store_attribute_groups(nil) unless retrieve_attribute_groups.nil?
    
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
      group = find_attribute_group(params[:attribute_group_id].to_i)
      
      unless group.person_attributes.blank?
        @default_attributes = group.person_attributes.sort_by{ |a| a.name }
      end
      
      @people = perform_people_search(params[:person_attribute_id], params[:page] || 1)
    end
    
  end
  
  def save_step_1
    if params[:subscribers].blank?
      flash[:error] = "At least one email is required to add to a list. The people you selected don't have an email."
      
      redirect_to synchronize_new_step_1_path
    else
      subscribers = params[:subscribers] #.uniq
      
      sub_arr = []
      
      subscribers.keys.each do |email|
        last_name = subscribers[email]['last_name']
        first_name = subscribers[email]['first_name']
        id = subscribers[email]['id']
        
        logger.debug "[SUBSCRIBER] email: #{email}, first_name: #{first_name}, last_name: #{last_name}, id: #{id}"
        
        sub_arr << {:email => email, :first_name => first_name, :last_name => last_name, :id => id}
      end
      
      session[:subscribers] = sub_arr
      
      # remove the attribute groups, we don't need them anymore
      store_attribute_groups nil
    
      redirect_to synchronize_new_step_2_path
    end
    
  end

  def step_2
    # retrieve sync from session
    hominid = Hominid::API.new(@current_account.mailchimp_key)
    @lists = hominid.lists['data']
  end
  
  def create
    subscribers = session[:subscribers]
    
    if subscribers.blank?
      flash[:error] = "Something went wrong and we could not retrieve a list of subscribers."
      redirect_to synchronize_new_step_1_path
    else
      hominid = Hominid::API.new(@current_account.mailchimp_key)
      
      lists = params[:lists]
      
      subscribers.collect! { |s| {:EMAIL => s[:email], :EMAIL_TYPE => 'html', :FNAME => s[:first_name], :LNAME => s[:last_name], :F1ID => s[:id]} }
      
      lists.each do |list|
        results = hominid.list_batch_subscribe(list, subscribers, {:double_opt_in => false, :update_existing => true})

        if results['errors'].length == 0
          # all subscribes were successful, write the record to our db
          sync = Synchronize.find_or_initialize_by_mailchimp_list_id(list)
          if sync.new_record?
            sync.account = @current_account
          else
            sync.updated_at = Time.now
          end
          
          sync.save
        else
          # TODO: Need to handle
        end
      end
      
      session[:subscribers] = nil
      
      redirect_to home_path
    end

  end
  
  def get_attributes
    group = find_attribute_group(params[:attribute_group_id].to_i)

    person_attributes = []
    
    unless group.person_attributes.blank?
      person_attributes = group.person_attributes.sort_by{ |a| a.name }
    end
    
    render :partial => "options_for_attributes", :locals => { :person_attributes => person_attributes }
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
  
  def perform_people_search(attribute_id, page)
    @search_data = nil
    people = []
    search_url = "#{current_user_session.api_url}people/Search.json?attribute=#{attribute_id}&page=#{page}&include=communications&recordsPerPage=100"
    search_raw = current_user_session.access_token.get(search_url)
    search_json = ActiveSupport::JSON.decode(search_raw.body)

    unless search_json.nil?
      @search_data = {:has_additional_pages => search_json['results']['@additionalPages'].to_i > 0, :page => search_json['results']['@pageNumber'].to_i, :total_records => search_json['results']['@totalRecords']}
      unless search_json['results']['person'].nil?
        search_json['results']['person'].each do |person|
          new_person = Person.new(person)
          people << new_person unless new_person.email.blank?
        end
      end
    end
    
    people
  end

end
