# encoding: utf-8

#require 'map_layers'
require 'map_layers/helpers/view_helpers'

module MapLayers
  # Rails 3+ initialization
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer 'map_layers.initialize' do
        MapLayers::Railtie.insert
      end
    end
  end

  class Railtie
    def self.insert
      #ActionController::Base.send(:include, MapLayers::JsExtension)
      #ActionView::Base.send(:include, MapLayers::JsExtension)
      ActionView::Base.send(:include, MapLayers::ViewHelper)

      Mime::Type.register "application/vnd.google-earth.kml+xml", :kml
      Mime::Type.register "application/gpx+xml", :gpx
    end
  end

end
