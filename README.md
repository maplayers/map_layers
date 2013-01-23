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

Add a second map layer, a vector layer and some more controls in the controller action:

``` ruby
# app/controller/your_controller.rb
@map = MapLayers::JsExtension::MapBuilder.new("map") do |builder, page|
  page << builder.map.add_layer(MapLayers::OpenLayers::OSM_MAPNIK)
  page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE)

  page << builder.map.add_control(MapLayers::OpenLayers::Control::LayerSwitcher.new)
  page << builder.map.add_control(MapLayers::OpenLayers::Control::Permalink.new('permalink'))
  page << builder.map.add_control(MapLayers::OpenLayers::Control::MousePosition.new)

  # add a vector layer to read from kml url
  page << builder.add_vector_layer('pikts', '/pictures.kml', :format => :kml)

  # initialize select, point, path, polygon and drag control for features
  page << builder.map_handler.initialize_controls('pikts_controls', 'pikts')

  # switch control mode, 'select' display popup on feature
  page << builder.map_handler.toggle_control('pikts_controls', 'select')

  page << builder.map.zoom_to_max_extent()
end

```

Add more options to your new map in the view

```
<!-- html map container -->
<%= map_layers_container(@map, :class => 'small_size', :include_loading => true) do %>
  <!-- this block is rendered inside the container -->
  <%= map_layers_localize_form_tag(localize_pictures_path) do |f| %>
    <%= text_field_tag(:search, params[:search]) %>
    <%= submit_tag(t('helpers.map_layers_localize_form.search')) %>
  <% end %>
<% end %>

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
  def add_marker
    # the no_init option tells to instanciate object for ajax use
    @map = MapLayers::JsExtension::MapBuilder.new("map", :no_init => true) do |builder, page|
      feat = MapLayers::JsExtension::JsVar.new('feat')

      # remove all existing feature in the layer
      page << builder.map_handler.remove_features('pikts')

      # add a new feature and save js var
      page << feat.assign(builder.map_handler.add_feature('pikts', 53.349772, -6.277858))

      # add description to display in the popup
      page << builder.map_handler.add_feature_attributes(feat, {:name => 'The Cobblestone', :description => 'Guinness please', :link => 'http://www.cobblestonepub.ie'})

      # center and zoom on this newly created feature
      page << builder.map_handler.set_center_on_feature(feat, 15)
    end
  end
```


```
<%= map_layers_container(@map, :class => 'small_size', :include_loading => true) do %>
  <!-- render this block inside the container -->
  <%= map_layers_localize_form_tag(localize_pictures_path) do |f| %>
    <%= text_field_tag(:search, params[:search]) %>
    <%= submit_tag(t('helpers.map_layers_localize_form.search')) %>
  <% end %>
<% end %>
```

``` ruby
  def localize
    @search = Geocoder.search(params[:search])

    @map = MapLayers::JsExtension::MapBuilder.new("map", :no_init => true) do |builder, page|
      feat = MapLayers::JsExtension::JsVar.new('feat')
      coordinates = @search[0].coordinates

      page << builder.map_handler.remove_features('pikts')
      page << feat.assign(builder.map_handler.add_feature('pikts', coordinates[0], coordinates[1]))
      page << builder.map_handler.add_feature_attributes(feat, {:name => @search[0].address.gsub(/\'/, '\''), :description => 'Move me to update form fields', :link => 'http://www.google.nl'})
      page << builder.map_handler.set_center_on_feature(feat, 15)
    end
  end
```

Then we include a marker layer in the map. Put this after the add_layer statements in the controller:

``` ruby
  page.assign("markers", Layer::Markers.new('Markers'))
  page << map.addLayer(:markers)
```

and then we implement the Ajax action:

``` ruby
  def add_marker
    render :update do |page|
      @markers = JsVar.new('markers')
      page << @markers.add_marker(OpenLayers::Marker.new(OpenLayers::LonLat.new(rand*50,rand*50)))
    end
  end
```

For accessing the marker layer in the Ajax action, we declare a Javascript variable with <tt>page.assign</tt> and access the variable later with the +JsVar+ wrapper.


OpenStreetMap in WGS84
----------------------

To overlay data in WGS84 projection you can use a customized Open Street Map:

``` ruby
  @map = MapLayers::Map.new("map") do |map, page|
    page << map.add_layer(MapLayers::GEOPOLE_OSM)
    page << map.zoom_to_max_extent()
  end
```

Publish your own data
---------------------

Create a model:

``` bash
  ./script/generate model --skip-timestamps --skip-fixture Place placeName:string countryCode:string postalCode:string lat:float lng:float
  rake db:migrate
```

Import some places:

``` bash
  ./script/runner "Geonames::Postalcode.search('Sidney').each { |pc| Place.create(pc.attributes.slice('placeName', 'postalCode', 'countryCode', 'lat', 'lng')) }"
```

Add a new controller with a map_layer:

``` ruby
  class PlacesController < ApplicationController

    map_layer :place, :text => :placeName

  end
```

And add a layer to the map:

``` ruby
  page << map.addLayer(Layer::GeoRSS.new("GeoRSS", "/places/georss"))
```

Other types of served layers:

``` ruby
  page << map.add_layer(Layer::GML.new("Places KML", "/places/kml", {:format=> JsExpr.new("OpenLayers.Format.KML")}))

  page << map.add_layer(Layer::WFS.new("Places WFS", "/places/wfs", {:typename => "places"}, {:featureClass => JsExpr.new("OpenLayers.Feature.WFS")}))
```


Spatial database support
------------------------

Using a spatial database requires GeoRuby[http://georuby.rubyforge.org/] and the Spatial Adapter for Rails:

``` bash
  sudo gem install georuby
  ruby script/plugin install svn://rubyforge.org/var/svn/georuby/SpatialAdapter/trunk/spatial_adapter
```

Install spatial functions in your DB (e.g. Postgis 8.1):

``` bash
  DB=map_layers_dev
  createlang plpgsql $DB
  psql -d $DB -q -f /usr/share/postgresql-8.1-postgis/lwpostgis.sql
```

Create a model:

``` bash
  ./script/generate model --skip-timestamps --skip-fixture WeatherStation name:string geom:point
  rake db:migrate
```

Import some weather stations:

``` bash
  ./script/runner "Geonames::Weather.weather(:north => 44.1, :south => -9.9, :east => -22.4, :west => 55.2).each { |st| WeatherStation.create(:name => st.stationName, :geom => Point.from_x_y(st.lng, st.lat)) }"
```

Add a new controller with a map_layer:

``` ruby
  class WeatherStationsController < ApplicationController

    map_layer :weather_stations, :geometry => :geom

  end
```

And add a WFS layer to the map:

``` ruby
  page << map.add_layer(Layer::WFS.new("Weather Stations", "/weather_stations/wfs", {:typename => "weather_stations"}, {:featureClass => JsExpr.new("OpenLayers.Feature.WFS")}))
```

License
-------

The MapLayers plugin for Rails is released under the MIT license.

Development
-----------

* Source hosted at [GitHub](https://github.com/dryade/map_layers).
* Report issues and feature requests to [GitHub Issues](https://github.com/dryade/map_layers/issues).

Pull requests are very welcome! Make sure your patches are well tested. Please create a topic branch for every separate change you make. Please **do not change** the version in your pull-request.


<em>Copyright (c) 2011 Luc Donnet, Dryade</em>
