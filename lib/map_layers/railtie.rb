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
      # TODO: Add a sub-module to avoid including the whole gem
      # into action_view
      ActionController::Base.send(:include, MapLayers)
      ActionView::Base.send(:include, MapLayers)
      ActionView::Base.send(:include, MapLayers::ViewHelpers)

      Mime::Type.register "application/vnd.google-earth.kml+xml", :kml
      Mime::Type.register "application/gpx+xml", :gpx
    end
  end

end
