class Synchronize < ActiveRecord::Base
  set_table_name "synchronize"
  
  validates_presence_of :account_id
  validates_presence_of :mailchimp_list_id
  
end
