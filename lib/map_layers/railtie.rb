require 'map_layers/helpers/view_helpers'

module MapLayers
  # Rails 3+ initialization
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer 'map_layers' do
        MapLayers::Railtie.insert
      end
    end
  end

  class Railtie
    def self.insert
      ActionView::Base.send(:include, MapLayers::ViewHelper)

      Mime::Type.register "application/vnd.google-earth.kml+xml", :kml
      Mime::Type.register "application/gpx+xml", :gpx
    end
  end

end
