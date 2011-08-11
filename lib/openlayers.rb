module OpenLayers

   def self.const_missing(sym)
     if OpenLayers.const_defined?(sym)
       OpenLayers.const_get(sym)
     else
       OpenLayers.const_set(sym, Class.new(MapLayers::JsClass))
     end
   end

end
