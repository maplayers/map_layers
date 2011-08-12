require 'map_layers'

ActionController::Base.send(:include, MapLayers)
ActionView::Base.send(:include, MapLayers)
ActionView::Base.send(:include, MapLayers::ViewHelpers)

Mime::Type.register "application/vnd.google-earth.kml+xml", :kml
