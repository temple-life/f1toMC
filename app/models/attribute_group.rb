class AttributeGroup
  attr_accessor :id, :uri, :name, :person_attributes
  
  def initialize(json=nil)
    unless json.nil?
      @id = json['@id'].to_i
      @uri = json['@uri']
      @name = json['name']
      unless json['attribute'].nil?
        @person_attributes = []
        json['attribute'].each do |person_attribute|
          @person_attributes << PersonAttribute.new(person_attribute)
        end
      end
    end
  end
  
end