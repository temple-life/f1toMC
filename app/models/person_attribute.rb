class PersonAttribute
  attr_accessor :id, :uri, :name
  
  def initialize(json=nil)
    unless json.nil?
      @id = json['@id'].to_i
      @uri = json['@uri']
      @name = json['name']
    end
  end
end