class Person
  attr_accessor :id, :uri, :first_name, :last_name, :goes_by, :suffix, :email, :status, :sub_status, :phone
  
  def initialize(json=nil)
    unless json.nil?
      @id = json['@id'].to_i
      @uri = json['@uri']
      @first_name = json['firstName']
      @goes_by = json['goesByName']
      @last_name = json['lastName']
      @suffix = json['suffix']
      
      unless json['status'].nil?
        @status = json['status']['name']
        unless json['status']['subStatus']['name'].nil?
          @sub_status = json['status']['subStatus']['name']
        end
      end
      
      unless json['communications'].nil?
        unless json['communications']['communication'].nil?
          json['communications']['communication'].each do |communication|
            case communication['communicationType']['@id']
              when "1" # home phone
                @phone = communication['communicationValue']
              when "4" # email
                if @email.nil?
                  unless communication['person']['@id'].blank?
                    @email = communication['communicationValue']
                  end
                end
            end
          end
        end
      end
    end
  end
  
  def casual_name
    @goes_by || @first_name
  end
  
end