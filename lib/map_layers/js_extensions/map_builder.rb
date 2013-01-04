module MapLayers
  module JsExtensions

    class MapBuilder
      include JsWrapper
      attr_reader :container, :map, :map_handler

      def initialize(map_name, options = {}, &block)
        @js = JsGenerator.new
        @container = map_name
        @map = Map.new(map_name, options)
        @map_handler = MapHandler.new(map, options)

        @js << @map.to_js(options)
        @js << @map_handler.to_js(options)
        yield(@map, @map_handler, @js) if block_given?
      end

      def to_js(options = {})
        no_script_tag = options[:no_script_tag]

        variables = []
        variables << map.variables
        variables << map_handler.variables

        method_name = "map_layers_init_#{container}"

        js = JsGenerator.new #(:included => true)

        js << "#{declare(variables.join(','), :declare_only => true)}"

        js << "#{@container} = null"
        js << "function #{method_name}() {\nif (#{@container} == null) {\n#{@js.to_s}}\n}"

        #js << "#{method_name}()"

        js.to_s.html_safe
      end

      def to_html(options = {})
        no_script_tag = options[:no_script_tag]

        html = ""
        html << "<script defer=\"defer\" type=\"text/javascript\">\n" if !no_script_tag
        html << to_js(options)
        html << "</script>" if !no_script_tag

        html.html_safe
      end
      alias_method :to_s, :to_html
    end

  end
end
