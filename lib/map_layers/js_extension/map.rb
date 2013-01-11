module MapLayers
  module JsExtension

    #Map viewer main class
    class Map
      include JsWrapper
      attr_reader :container, :layers
      attr_accessor :variables

      def initialize(map_name, options = {}, &block)
        set_variable map_name

        @container = map_name
        #@handler = "#{map}_handler"
        #@variable = map
        @layers = []
        @variables = [map_name]
        @options = {:theme => false}.merge(options)
        @js = JsGenerator.new(:included => true)
  #      @icons = []
        yield(self, @js) if block_given?
      end

      # add_layer method which save the name of layer included before calling the javascript action
      def add_layer(*args)
        type = args.first.class.to_s.split(":").last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym rescue nil
        @layers << type unless type.nil? || layers.include?(type)

        # call default javascript action
        method_missing('add_layer', *args)
      end

      #Outputs in JavaScript the creation of a OpenLayers.Map object
      def create
        #"new OpenLayers.Map('#{@container}', #{JsWrapper::javascriptify_variable(@options)})"
        OpenLayers::Map.new(@container, @options) #.to_javascript
      end

      def js(options = {})
        #@js << assign_to(@container)
pp "####################### JS"
pp "container "
pp @container
        @js << JsVar.new(@container).assign(create)
        @js
      end
    end

  end
end
