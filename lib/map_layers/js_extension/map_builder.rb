module MapLayers
  module JsExtension

    class MapBuilder
      include JsWrapper
      attr_reader :js_map, :js_handler
      attr_reader :options
      attr_reader :no_init
      attr_reader :js

      def initialize(map_name, options = {}, &block)
        self.variable = map_name
        @no_init = options[:no_init] || false

        @js = JsGenerator.new

        @js_map = Map.new(map_name, options)
        @js_handler = MapHandler.new(@js_map, options)

        unless no_init
          @js << @js_map.js
          @js << @js_handler.js
        end

        yield(self, @js) if block_given?
      end

      def create_vector_layer(name, url, options = {})
        projection = options[:projection] || JsExpr.new("#{@js_map.variable}.displayProjection")
        format = options[:format] || nil
        protocol = url.nil? ? {} : {
            :strategies => [OpenLayers::Strategy::Fixed.new], #, OpenLayers::Strategy::Cluster.new],
            :protocol => OpenLayers::Protocol::HTTP.new({
              :url => url,
              :format => format
            })
          }

        OpenLayers::Layer::Vector.new(name, {
            :projection => projection
          }.merge(protocol))
      end

      def replace_vector_layer(name, url, options = {})
        js = JsGenerator.new
        js << JsVar.new(@js_handler.variable).destroy_layer(name)
        js << add_vector_layer(name, url, options)

        js.to_s.html_safe
      end

      def add_vector_layer(name, url, options = {})
        no_global = options[:no_global]
        no_controls = options[:no_controls]
        format = options[:format] || :kml
        layer_name = name.parameterize

        js = JsGenerator.new

        # TODO : add GPX support
        frmt = case format
        #when :gpx
        #  OpenLayers::Format::GPX.new
        when :georss
        else # :kml is the default
          OpenLayers::Format::KML.new({:extractStyles => true, :extractAttributes => true})
        end

        layer = create_vector_layer(name, url, options.merge(
            :format => frmt))

        @js_map.variables << layer_name

        js << JsVar.new(layer_name).assign(layer)
        js << JsVar.new(@js_map.variable).add_layer(JsVar.new(layer_name))

        js.to_s.html_safe
      end



      def to_js(js_code = nil, options = {})
        method_name = "map_layers_init_#{variable}"

        variables = []
        # map js variables
        variables << js_map.variable
        variables.concat(js_map.variables)
        # js_handler js variable
        variables << js_handler.variable

        js_gen = JsGenerator.new #(:included => true)

        if no_init
          js_gen = @js
        else
          # declare variables
          js_gen << declare(variables.join(','))

          # init builder variable to null, to avoid multiple map loading
          js_gen << JsExpr.new("#{variable} = null")
          js_gen << "function #{method_name}() {"
          js_gen << "if (#{variable} == null) {"
          js_gen << "// base map code"
          js_gen << "#{@js.to_s}"
          unless js_code.nil? || !js_code.is_a?(String)
            js_gen << "// additionnal code"
            js_gen << js_code
          end
          js_gen << "}"
          js_gen << "}"
        end

        js_gen.to_s.html_safe
      end

      def to_html(js_code = nil, options = {})
        no_script_tag = options[:no_script_tag]

        html = ""
        html << no_script_tag ? to_js(js_code, options) : javascript_tag(to_js(js_code, options))

        html.html_safe
      end
      alias_method :to_s, :to_html
    end

  end
end
