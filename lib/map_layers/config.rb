module MapLayers
  class Config
    include ActiveSupport::Configurable
    config_accessor :model_id, :id, :lat, :lon, :geometry, :text

    config.model_id = model_id.to_s.pluralize.singularize
    config.id = :id
    config.lat = :lat
    config.lon = :lon
    #config.geometry =
    config.text = :name

    def self.configure(&block)
      yield config
    end

    def model
      @model ||= config.model_id.to_s.camelize.constantize
    end
  end
end
