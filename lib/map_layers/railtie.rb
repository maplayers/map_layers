# encoding: utf-8

require 'map_layers'
require 'map_layers/view_helpers'

module MapLayers
  # Rails 3 initialization
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'map_layers.initialize' do
        MapLayers::Railtie.insert
      end
    end

  end

  class Railtie
    def self.insert
      ActionController::Base.send(:include, MapLayers)
      ActionView::Base.send(:include, MapLayers)
      ActionView::Base.send(:include, MapLayers::ViewHelpers)
      Mime::Type.register "application/vnd.google-earth.kml+xml", :kml
    end
  end

end
