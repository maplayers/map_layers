module MapLayers
  module Builder
    class Feature
      attr_reader :name, :latitude, :longitude, :options
      attr_reader :attributes

      def initialize(name, latitude, longitude, options = {})
        @name = name
        @latitude = latitude
        @longitude = longitude
        @attributes = options.delete(:attributes) || {}
        @options = options
      end

      def add_attributes(attributes)
        @attributes.merge!(attributes)
      end

      def js_var
        MapLayers::JsExtension::JsVar.new(name)
      end
    end
  end
end
