class Account < ActiveRecord::Base
  validates_presence_of :church_code
end
