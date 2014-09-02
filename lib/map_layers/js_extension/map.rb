module MapLayers
  module JsExtension

    class Map
      include JsWrapper
      attr_reader :layers, :js
      attr_accessor :variables

      def initialize(map_name, options = {}, &block)
        self.variable = map_name

        # layers used for current map
        @layers = []

        # js variables used for current map (at least one for each layer)
        @variables = []

        @options = {:theme => false, :controls => []}.merge(options)
        @js = JsGenerator.new #(:included => true)
        @js << JsVar.new(variable).assign(create)
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
        OpenLayers::Map.new(variable, @options)
      end
    end

  end
end
