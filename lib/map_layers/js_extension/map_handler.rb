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

      #Outputs in JavaScript the creation of a OpenLayersHandlers.SimpleMapHandler object
      def create
        OpenLayersHandlers::SimpleMapHandler.new(JsVar.new(@map))
      end
    end

  end
end
