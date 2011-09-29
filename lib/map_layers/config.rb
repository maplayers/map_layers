module MapLayers 

 class Config
    attr_reader :model_id, :id, :lat, :lon, :geometry, :text
    
    def initialize(model_id, options)
      @model_id = model_id.to_s.pluralize.singularize
      @id = options[:id] || :id
      @lat = options[:lat] || :lat
      @lon = options[:lon] || :lng
      @geometry = options[:geometry]
      @text = options[:text] || :name
    end
    
    def model
      @model ||= @model_id.to_s.camelize.constantize
    end
  end

end
