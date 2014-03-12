require 'map_layers/builder/layer'
require 'map_layers/builder/vector_layer'
require 'map_layers/builder/map'
require 'map_layers/builder/feature'

module MapLayers
  module Builder
    def self.create(name, options = {}, &block)
      map = Map.new(name, options)

      yield map if block_given?

      map
    end

    def self.update(name, options = {}, &block)
      create(name, options.merge(:no_init => true), &block)
    end
  end
end
