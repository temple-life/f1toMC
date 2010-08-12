class Person
  attr_accessor :id, :uri, :first_name, :last_name, :goes_by, :suffix, :email, :status, :phone
  
  def initialize(json=nil)
    unless json.nil?
      @id = json['@id'].to_i
      @uri = json['@uri']
      @first_name = json['firstName']
      @goes_by = json['goesByName']
      @last_name = json['lastName']
      @suffix = json['suffix']
    end
  end
end