# MapLayers

MapLayers makes it easy to integrate a dynamic map in a Rails application. It can display map tiles and markers loaded from many different data sources.
The included map viewer is [OpenLayers](http://www.openlayers.org/).
With MapLayers you can :
- create map using all available options from openlayers
- add/remove/show/hide layers
- handle events triggered on maps

Getting Started
---------------

Install the latest version of the plugin:

    gem install map_layers

Or with bundler add to your Gemfile :

    gem "map_layers"

Generate a kml renderer

``` bash
rails generate map_layers:builder --builder_type kml
```

Initialization of the map
-------------------------

Add the map viewer initialization to the index action in the controller :

``` ruby
@map = MapLayers::JsExtension::MapBuilder.new("map") do |builder, page|
  page << builder.map.add_layer(MapLayers::OpenLayers::OSM_MAPNIK)
  page << builder.map.zoom_to_max_extent()
end
```

Add the container and scripts to your view :

```
<!-- html map container -->
<%= map_layers_container(@map, :class => 'small_size', :include_loading => true) %>

<!-- map_layers js scripts and if necessary its dependencies -->
<%= map_layers_includes(@map, :onload => true) %>
```

Multiple layers
---------------

Add a second map layer, some vector layers and some more controls in the controller action:

``` ruby
# app/controller/your_controller.rb
@map = MapLayers::JsExtension::MapBuilder.new("map") do |builder, page|
  page << builder.map.add_layer(MapLayers::OpenLayers::OSM_MAPNIK)
  page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE)

  page << builder.map.add_control(MapLayers::OpenLayers::Control::LayerSwitcher.new)
  page << builder.map.add_control(MapLayers::OpenLayers::Control::Permalink.new('permalink'))
  page << builder.map.add_control(MapLayers::OpenLayers::Control::MousePosition.new)

  # Add a vector layer to read from kml url
  page << builder.add_vector_layer('pikts', '/pictures.kml', :format => :kml)

  # Add an empty vector layer
  page << builder.add_vector_layer('services', nil, :format => :kml)

  # Initialize select, point, path, polygon and drag control for features
  # you may want to handle event on only one layer
  #page << builder.map_handler.initialize_controls('map_controls', 'pikts')
  # if you need to handle events on multiple layers, add all theses layers to the initializer
  page << builder.map_handler.initialize_controls('map_controls', ['pikts', 'services'])

  # Switch control mode, 'select' display popup on feature
  # available mode are :
  #   - select, to display popup
  #   - point, to create points on map
  #   - path, to draw path on map
  #   - polygon, to draw polygons on map
  #   - drag, to move features
  #   - none, to disable all controls
  page << builder.map_handler.toggle_control('map_controls', 'select')

  page << builder.map.zoom_to_max_extent()
end

```

Add more options to your new map in the view

```
<!-- html map container -->
<%= map_layers_container(@map, :class => 'small_size', :include_loading => true) %>

<!-- map layers js scripts -->
<%= map_layers_includes(@map, :onload => true) do %>
  $(document).ready(function() {

    // you may add openlayers js code (%{map} and %{map_handler} are replaced the corresponding js objects)

    // setDragCallback handle feature drag events
    %{map_handler}.setDragCallback('onComplete', function(feature) {
      // and allows you to fill a form on feature drag
      fillFormWithFeature(feature);
    });

    // handle map move and add features in the center and each corners on map move
    %{map}.events.register("moveend", map, function() {
      var center = %{map}.getCenter().clone().transform( %{map}.getProjectionObject(),new OpenLayers.Projection("EPSG:4326") );
      alert("moveend : " + center);
      feature = %{map_handler}.addFeature('pikts', center.lat, center.lon);

      // use any custom js method at your convenience
      fillFormWithLonlat(feature);

      // add features to each map corners
      bounds = map.getExtent().toGeometry().getBounds().transform( map.getProjectionObject(),new OpenLayers.Projection("EPSG:4326") );
      %{map_handler}.addFeature('pikts', bounds.top, bounds.left);
      %{map_handler}.addFeature('pikts', bounds.top, bounds.right);
      %{map_handler}.addFeature('pikts', bounds.bottom, bounds.left);
      %{map_handler}.addFeature('pikts', bounds.bottom, bounds.right);
    });

  });

<% end %>
```

There are more predefined layer types available:

  - OSM_MAPNIK
  - GOOGLE
  - GOOGLE_SATELLITE
  - GOOGLE_HYBRID
  - GOOGLE_PHYSICAL

Updating the map
----------------

Now we want to add some simple markers in an Ajax action.
First we add a remote link in the view:

```
<%= link_to 'Add marker', add_marker_path, :remote => true %>
```

Add this new method in your controller, and do not forget the to add the corresponding route :

``` ruby
# app/controllers/pictures_controller.rb
def add_marker
  # the no_init option tells to instanciate object for ajax use
  @map = MapLayers::JsExtension::MapBuilder.new("map", :no_init => true) do |builder, page|
    # Create a js variable to handle feature.
    # This is not necessary but used here to add attributes to this feature
    feat = MapLayers::JsExtension::JsVar.new('feat')

    # Remove all existing feature in the layer
    page << builder.map_handler.remove_features('pikts')

    # Add a new feature and save js var
    page << feat.assign(builder.map_handler.add_feature('pikts', 53.349772, -6.277858))

    # Add description to display in the popup
    page << builder.map_handler.add_feature_attributes(feat, {:name => 'The Cobblestone', :description => 'Guinness please', :link => 'http://www.cobblestonepub.ie'})

    # Center and zoom on this newly created feature
    page << builder.map_handler.set_center_on_feature(feat, 15)
  end
end
```

Then create a template to return js code

```
// app/view/pictures/add_marker.js.erb
<%= @map.to_js %>
```

Even if you're absolutely free to customize the map to your needs, MapLayers
includes a helper to add localize method in a standardized way.

```
<!-- map_layer container including a form -->
<%= map_layers_container(@map, :class => 'small_size', :include_loading => true) do %>
  <!-- render this block inside the container -->
  <%= map_layers_localize_form_tag(localize_pictures_path) do |f| %>
    <%= text_field_tag(:search, params[:search]) %>
    <%= submit_tag(t('helpers.map_layers_localize_form.search')) %>
  <% end %>
<% end %>
```

The localization method is up to you, here is a simple example using [Geocoder gem](https://github.com/alexreisner/geocoder).

``` ruby
  def localize
    @search = Geocoder.search(params[:search])

    @map = MapLayers::JsExtension::MapBuilder.new("map", :no_init => true) do |builder, page|
      feat = MapLayers::JsExtension::JsVar.new('feat')
      coordinates = @search[0].coordinates

      # remove all features from the layer
      page << builder.map_handler.remove_features('pikts')

      # add the new one at the right coordinates
      page << feat.assign(builder.map_handler.add_feature('pikts', coordinates[0], coordinates[1]))

      # add description to this point
      page << builder.map_handler.add_feature_attributes(feat, {:name => @search[0].address.gsub(/\'/, '\''), :description => 'Move me to update form fields', :link => 'http://www.google.fr'})

      # and center map on this feature
      page << builder.map_handler.set_center_on_feature(feat, 15)
    end
  end
```

License
-------

The MapLayers plugin for Rails is released under the MIT license.

Copyright (c) 2013 La Fourmi Immo including original code Copyright (c) 2011 Luc Donnet, Dryade
