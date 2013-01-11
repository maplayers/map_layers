require 'pp'

module MapLayers
  module JsExtension

    class MapBuilder
      include JsWrapper
      attr_reader :container, :map, :map_handler

      def initialize(map_name, options = {}, &block)
        @js = JsGenerator.new
        @container = map_name
        @map = Map.new(map_name, options)
        @map_handler = MapHandler.new(@map, options)

        #@js << "// MAP BEGIN"
        @js << @map.js
        #@js << "// MAP END"
        #@js << "// MAP_HANDLER BEGIN"
        @js << @map_handler.js
        #@js << "// MAP_HANDLER END"
        #yield(@map, @map_handler, @js) if block_given?
        yield(self, @js) if block_given?
      end

      def create_vector_layer(name, url, options = {})
        projection = options[:projection] || JsExpr.new("#{@map.container}.displayProjection")
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
        js = JsGenerator.new(:included => true)
        #map_handler.destroyLayer('pikts');
        js << JsVar.new(@map_handler.container).destroy_layer(name)
        js << add_vector_layer(name, url, options)

        js.to_s.html_safe
      end

      def add_vector_layer(name, url, options = {})
        no_global = options[:no_global]
        no_controls = options[:no_controls]
        format = options[:format] || :kml
        layer_name = name.parameterize

        js = JsGenerator.new(:included => true)

        frmt = case format
        when :georss
        else # :kml is the default
          OpenLayers::Format::KML.new({:extractStyles => true, :extractAttributes => true})
        end

        layer = create_vector_layer(name, url, options.merge(
            :format => frmt))

        @map.variables << layer_name

        #js.assign(layer_name, layer) #, :declare => !no_global)
        js << JsVar.new(layer_name).assign(layer)
        js << JsVar.new(@map.container).add_layer(JsVar.new(layer_name))
#pp JsVar.new(@map.container).add_layer(JsVar.new(layer_name)).class
        #js << add_map_handler(name, options) unless no_controls

        js.to_s.html_safe
      end



      def to_js(options = {})
        method_name = "map_layers_init_#{container}"

        variables = []
        variables.concat(map.variables)
        variables.concat(map_handler.variables)

        js = JsGenerator.new #(:included => true)

        #variables.each do |v|
        #  js << declare(v)
        #end
        js << declare(variables.join(','))

        js << JsExpr.new("#{@container} = null")
        js << "function #{method_name}() {\nif (#{@container} == null) {\n#{@js.to_s}}\n}"

        #js << "#{method_name}()"

        js.to_s.html_safe
      end

      def to_html(options = {})
        no_script_tag = options[:no_script_tag]

        html = ""
        #html << "<script defer=\"defer\" type=\"text/javascript\">\n" if !no_script_tag
        html << no_script_tag ? to_js(options) : javascript_tag(to_js(options))
        #html << "</script>" if !no_script_tag

        html.html_safe
      end
      alias_method :to_s, :to_html
    end

  end
end
