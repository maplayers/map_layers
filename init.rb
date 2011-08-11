require 'openlayers'
require 'map_layers'
require 'map'
require 'view_helpers'
require 'js_wrapper'

ActionController::Base.send(:include, MapLayers)
ActionView::Base.send(:include, MapLayers)
ActionView::Base.send(:include, MapLayers::ViewHelpers)

Mime::Type.register "application/vnd.google-earth.kml+xml", :kml
