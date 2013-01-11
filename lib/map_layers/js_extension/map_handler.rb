module MapLayers
  module JsExtension

    class MapHandler
      include JsWrapper
      attr_reader :js

      def initialize(map, options = {}, &block)
        self.variable = options[:name] || "#{map.variable}_handler"

        @map = map.variable
        @js = JsGenerator.new
        @js << JsVar.new(variable).assign(create)

        yield(self, @js) if block_given?
      end

      #Outputs in JavaScript the creation of a OpenLayers.Map object
      def create
        JsExpr.new("new MapLayers.SimpleMapHandler(#{@map})")
        # OPTIMIZE: find a way to return such line
        #SimpleMapHandler.new(@map).to_javascript
      end
    end

  end
end
