module MapLayers
  module Builder
    class Map
      attr_accessor :options
      attr_reader :js_builder

      def initialize(name, options = {}, &block)
        self.options = options
        @js_builder = MapLayers::JsExtension::MapBuilder.new(name, options)
      end

      def add_layer(layer)
        case layer
        when VectorLayer
          @js_builder.js << @js_builder.add_vector_layer(layer.name, layer.url, :format => layer.format)
        else #
          @js_builder.js << @js_builder.js_map.add_layer(layer)
        end
      end

      def add_control(control, options = {})
        @js_builder.js << @js_builder.add_control(control)
      end

      def add_feature(layer, feature)
        feat = MapLayers::JsExtension::JsVar.new(feature.name)

        @js_builder.js << feat.assign(@js_builder.js_handler.add_feature(layer, feature.latitude, feature.longitude, feature.options))

        @js_builder.js << @js_builder.js_handler.add_feature_attributes(feat, feature.attributes)
      end

      def set_center_on_feature(feature, zoom = nil)
        feat = MapLayers::JsExtension::JsVar.new(feature.name)
        @js_builder.js << @js_builder.js_handler.set_center_on_feature(feat, 15)
      end

      def zoom_to_max_extent
        @js_builder.js << @js_builder.map.zoom_to_max_extent
      end

      # method missing --> map_handler
      def method_missing(method, *args, &block)
        @js_builder.js << @js_builder.js_handler.send(method, *args)
      end
    end
  end
end
