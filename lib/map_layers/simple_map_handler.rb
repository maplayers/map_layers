module MapLayers
  module SimpleMapHandler
    # Javascriptify missing constant
    def self.const_missing(sym)
      if SimpleMapHandler.const_defined?(sym)
        SimpleMapHandler.const_get(sym)
      else
        SimpleMapHandler.const_set(sym, Class.new(MapLayers::JsExtension::JsClass))
      end
    end

  end
end
