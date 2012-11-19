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

puts "toto"
      config.before_configuration do
puts "is"
        if ::Rails.root.join("public/javascripts/openlayers.min.js").exist?
          jq_defaults = %w(openlayers)
          jq_defaults.map!{|a| a + ".min" } if ::Rails.env.production? || ::Rails.env.test?
        else
          jq_defaults = ::Rails.env.production? || ::Rails.env.test? ? %w(openlayers.min) : %w(openlayers)
        end

        # Merge the jQuery scripts, remove the Prototype defaults and finally add 'jquery_ujs'
        # at the end, because load order is important
        if config.action_view.javascript_expansions
puts "here #{jq_defaults}"
          config.action_view.javascript_expansions[:defaults] |= jq_defaults
puts "#{config.action_view.javascript_expansions[:defaults]}"
        end

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
