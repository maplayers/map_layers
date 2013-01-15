require 'map_layers/version'
require 'map_layers/config'

require 'map_layers/js_extension/js_wrapper'
require 'map_layers/open_layers'
require 'map_layers/open_layers_handlers'
require 'map_layers/js_extension/map'
require 'map_layers/js_extension/map_handler'
require 'map_layers/js_extension/map_builder'

require 'map_layers/railtie'
require 'map_layers/engine'

module MapLayers # :nodoc:

#  # extend the class that include this with the methods in ClassMethods
#  def self.included(base)
#    base.extend(ClassMethods)
#  end
#
#  def map_layers_config
#    self.class.map_layers_config
#  end
#
#  module ClassMethods
#
#    def map_layer(model_id = nil, options = {})
#      options.assert_valid_keys(:id, :lat, :lon, :geometry, :text)
#
#      # converts Foo::BarController to 'bar' and FooBarsController to 'foo_bar' and AddressController to 'address'
#      model_id = self.to_s.split('::').last.sub(/Controller$/, '').pluralize.singularize.underscore unless model_id
#
#      # create the configuration
#      @map_layers_config = MapLayers::Config::new(model_id, options)
#    end
#
#    def map_layers_config
#      @map_layers_config || self.superclass.instance_variable_get('@map_layers_config')
#    end
#
#  end
#
end
