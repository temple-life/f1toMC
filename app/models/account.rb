class Account < ActiveRecord::Base
  has_many :synchronize
  
  validates_presence_of :church_code
end
