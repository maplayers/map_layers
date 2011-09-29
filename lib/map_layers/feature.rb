module MapLayers
 
 class Feature < Struct.new(:text, :x, :y, :id)
    attr_accessor :geometry
    def self.from_geom(text, geom, id = nil)
      f = new(text, geom.x, geom.y, id)
      f.geometry = geom
      f
    end
  end

end
