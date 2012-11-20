# encoding: utf-8

require 'map_layers'
require 'map_layers/view_helpers'

module MapLayers
  # Rails 3 initialization
  if defined? Rails::Railtie
    #require 'rails'
    class Railtie < Rails::Railtie
      initializer 'map_layers.initialize' do
        MapLayers::Railtie.insert
      end

#      config.before_configuration do
#        if ::Rails.root.join("public/javascripts/openlayers.debug.js").exist?
#          openlayers_defaults = %w(OpenLayers)
#          openlayers_defaults.map!{|a| a + ".debug" } if ::Rails.env.development?
#        else
#          openlayers_defaults = ::Rails.env.production? || ::Rails.env.test? ? %w(openlayers.min) : %w(openlayers)
#        end
#
#        # Merge the openlayers script # at the end, because load order is important
#        if config.action_view.javascript_expansions
#          config.action_view.javascript_expansions[:defaults] |= openlayers_defaults
#        end
#
#      end
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
