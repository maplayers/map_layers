module MapLayers
  module Builder
    class Map
      attr_accessor :options
      attr_reader :map_builder

      def initialize(name, options = {}, &block)
        self.options = options
        @map_builder = MapLayers::JsExtension::MapBuilder.new(name, options)
      end

      def add_layer(layer)
        case layer
        when VectorLayer
          @map_builder.js << @map_builder.add_vector_layer(layer.name, layer.url, :format => layer.format)
        else #
          @map_builder.js << @map_builder.map.add_layer(layer)
        end
      end

      def add_control(control, options = {})
        @map_builder.js << @map_builder.add_control(control)
      end

      def add_feature(layer, feature)
        feat = MapLayers::JsExtension::JsVar.new(feature.name)

        @map_builder.js << feat.assign(@map_builder.map_handler.add_feature(layer, feature.latitude, feature.longitude, feature.options))

        @map_builder.js << @map_builder.map_handler.add_feature_attributes(feat, feature.attributes)
      end

      def set_center_on_feature(feature, zoom = nil)
        feat = MapLayers::JsExtension::JsVar.new(feature.name)
        @map_builder.js << @map_builder.map_handler.set_center_on_feature(feat, 15)
      end

      def zoom_to_max_extent
        @map_builder.js << @map_builder.map.zoom_to_max_extent
      end

      # method missing --> map_handler
      def method_missing(method, *args, &block)
        @map_builder.js << @map_builder.map_handler.send(method, *args)
      end
    end
  end
end
