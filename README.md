# MapLayers [![Build Status](https://travis-ci.org/dryade/map_layers.png)](http://travis-ci.org/dryade/map_layers?branch=master) [![Dependency Status](https://gemnasium.com/dryade/map_layers.png)](https://gemnasium.com/dryade/map_layers) [![Code Climate](https://codeclimate.com/github/dryade/map_layers.png)](https://codeclimate.com/github/dryade/map_layers)

MapLayers makes it easy to integrate a dynamic map in a Rails application. It can display map tiles and markers loaded from many different data sources.
The included map viewer is [OpenLayers](http://www.openlayers.org/).

With MapLayers you can :
- create map using all available options from OpenLayers
- add/remove/show/hide layers
- handle events triggered on maps

Getting Started
---------------

Install the latest version of the plugin:

    gem install map_layers

Or with bundler add to your Gemfile :

    gem 'map_layers'


Initialization of the map
-------------------------

Include required stylesheets in your assets :

```
/*
 * ... in your scss (application.css.scss) file
 *= require OpenLayers.style
 *= require map_layers
*/
```

Define the size of your map container

```
.map_container.small_size{
  width: 400px;
  height: 400px;
}

```

Include required javascript in your assets :

```
// ... in your js (application.js) file
//= require OpenLayers
//= require map_layers

```


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

Adding feature may be done manually from coordinates or using a renderer. This
later option allows to localize objects in an easy way. Consider the following
example, you have pictures taken from all around the world and you want to
display them on a map.

Firstly, generate a renderer compatible with `map_layers`. For now, the only
format supported is KML, but we'll add other format such as GPX soon.
This renderer is an xml builder prepared to display data in a way handled by OpenLayers.

Generate a kml renderer

``` bash
rails generate map_layers:builder --builder_type kml
```

Now you may want to customize your renderer, even if it may not be necessary.
Renderer are stored in `app/view/map_layers/`.

By default, the standard renderer allow objects responding to :

  - latitude
  - longitude
  - name
  - description
  - altitude (replaced by 0 if not found)

If you need something else, other markers or more attributes, customize the renderer.
You may need to have all the icons in the asset/public directory to avoid Cross-Domain js error.

Then you'll need to respond to KML format, do this by adding the following line in the controller.

```
# app/controllers/pictures_controller.rb
def index
  # ...

  respond_to do |format|
    # ...

    # add this line to respond to format kml using your renderer
    format.kml { render 'map_layers/index' }
  end
end
```

And finally prepare a new map, including more layers and some more controls.

``` ruby
# app/controller/your_controller.rb
@map = MapLayers::JsExtension::MapBuilder.new("map") do |builder, page|
  # OpenStreetMap layer
  page << builder.map.add_layer(MapLayers::OpenLayers::OSM_MAPNIK)

  # Google layer
  page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE)

  # Google Satellite layer
  page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE_SATELLITE)

  # Google Hybrid layer
  page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE_HYBRID)

  # Google Physical layer
  page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE_PHYSICAL)


  # Add a button to hide/show layers
  page << builder.map.add_control(MapLayers::OpenLayers::Control::LayerSwitcher.new)

  # Add a link for permanent url
  page << builder.map.add_control(MapLayers::OpenLayers::Control::Permalink.new('permalink'))

  # Add mouse coordinates
  page << builder.map.add_control(MapLayers::OpenLayers::Control::MousePosition.new)

  # Add a vector layer to read from kml url
  page << builder.add_vector_layer('pikts', '/pictures.kml', :format => :kml)

  # Add an empty vector layer
  page << builder.add_vector_layer('services', nil, :format => :kml)

  # Initialize select, point, path, polygon and drag control for features
  # you may want to handle event on only one layer
  #page << builder.map_handler.initialize_controls('map_controls', 'pikts')
  # if you need to handle events on multiple layers, add all theses layers to the initializer
  # drag events and draw (point, path, polygon) events only works on the first layer, in this case 'pikts'
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
  // Js code here, to be added after the map itself
  // you may add openlayers js code (%{map} and %{map_handler} are replaced the corresponding js objects)

  // setDragCallback handle feature drag events
  %{map_handler}.setDragCallback('onComplete', function(feature) {
    // and allows you to fill a form on feature drag
    fillFormWithFeature('<%= @map.variable %>', feature);
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
<% end %>
```

`MapLayers` is shipped with a js `map_handler` to perform easily tasks on map.

This handy to :

- add/remove feature from layer
- handle popups on feature
- show/hide/remove layers
- center map on feature/coordinates
- handle events on feature or on the map

You may use it in a view :

```
<!-- Toggle layout visibility -->
<%= link_to 'Toggle layer', '#', :onclick => "#{@map.map_handler.toggle_layer('pikts')}; return false;" %>

<!-- Toggle Popup Infowindow -->
<%= link_to 'Toggle popup', '#', :onclick => "#{@map.map_handler.toggle_feature_popup(@map.map_handler.get_layer_feature_by_nb('pikts', 0))}; return false;" %>

<!-- Center on the first feature -->
<%= link_to 'Center', '#', :onclick => "#{@map.map_handler.set_center_on_feature_by_nb("pikts", 0, 15)}; return false;" %>

<!-- Center on the last feature without zooming -->
<%= link_to 'Center without zoom', '#', :onclick => "#{@map.map_handler.set_center_on_feature_by_nb("pikts", -1)}; return false;" %>

<!-- Set control mode for layouts events -->
<%= link_to 'Set control to Drag', '#', :onclick => "#{@map.map_handler.toggle_control('map_controls', 'drag')}; return false;" %>
<%= link_to 'Set control to Select', '#', :onclick => "#{@map.map_handler.toggle_control('map_controls', 'select')}; return false;" %>
```


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

Now another example handling multiple map on a single page.

```
# app/controllers/<obj>_controller.rb
def localize
  @search = Geocoder.search(params[:search])

  layer = params[:layer]
  map_name = params[:map]

  @map = MapLayers::JsExtension::MapBuilder.new(map_name, :no_init => true) do |builder, page|
    feat = MapLayers::JsExtension::JsVar.new('feat')

    unless @search.nil? || @search[0].nil?
      coordinates = @search[0].coordinates
      page << builder.map_handler.remove_features(layer)
      page << feat.assign(builder.map_handler.add_feature(layer, coordinates[0], coordinates[1]))
      page << builder.map_handler.add_feature_attributes(feat, {:name => @search[0].address.gsub(/\'/, '\''), :description => 'Move me to update form fields', :link => 'http://www.google.ie'})
      page << builder.map_handler.set_center_on_feature(feat, 15)
    end
  end
end
```

```
// app/views/<obj>/localize.js.erb
<%= @map.to_js %>
mapLayersLoading().hide();
mapLayersFillFormWithFeature('<%= @map.variable %>', feat);
```


Updating form fields
--------------------

You may want to review localization in a form, MapLayers include an easy way to fill latitude/longitude form fields.
To do this, include the following code in your view.

```
<%= map_layers_form_fields_container(@map) do %>
  <!-- add class 'localize_me' to the fields you want to use for geolocalization -->
  <%= f.text_field :street, :class => 'localize_me' %>
  <%= f.text_field :city, :class => 'localize_me' %>

  ...
  <!-- add class 'latitude_field'/'longitude_field' to the appropriate fields where you want to set the result -->
  <%= f.text_field :latitude, :readonly => true, :class => 'latitude_field' %>
  <%= f.text_field :longitude, :readonly => true, :class => 'longitude_field' %>

  ...
  <!-- adapt the next line to match the previous 'localize' method and to your map layer name -->
  <%= link_to 'localize', localize_<objects>_path(:type => 'address'), :data => {:layer => 'markers'}, :class => 'map_layers localize_form_fields' %>
<% end %>

<%= map_layers_container(@map, :class => 'big_map_size', :include_loading => true) %>

<%= map_layers_includes(@map, :onload => false) do -%>
%{map_handler}.setDragCallback('onComplete', function(feature) {
  mapLayersFillFormWithFeature('%{map}', feature);
});
<% end %>
```

Map dynamic loading
-------------------

For those of you who need to load google maps in ajax, it is possible but you
have to add a dynamic initializer.

`map_layers_container` helper is adding a css class for each map layer you load
in the container. It is later possible to use it for google maps dynamic
loading.

You may find here an example to add before map initialization.

```
function mapLayersInitializerModal(){
  // if your map container include a google maps layer
  // we want to dynamicaly add a <script> to the dom
  $map = $('#modal').find('div.maplayers-google');
  if($map.length && (typeof google == 'undefined')){
    var s = document.createElement('script');
    s.type = 'text/javascript';
    s.src = 'https://maps.googleapis.com/maps/api/js?sensor=false&callback=gmapsinitialize';
    document.body.appendChild(s);
  }
}

function gmapsinitialize() {
  var mapOptions = {
    zoom: 8,
    center: new google.maps.LatLng(48.397, 7.744),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  $map = $('#modal').find('div.maplayers-google');
  if($map.length > 0){
    var map = new google.maps.Map($map[0], mapOptions);
  }
}

$(function() {
  // call mapLayersInitializerModal() when appropriated depending of your
  // application
});
```


License
-------

The MapLayers plugin for Rails is released under the [AGPL](http://www.gnu.org/licenses/agpl-3.0.en.html "GNU AFFERO GENERAL PUBLIC LICENSE") license.

Copyright (c) 2013 La Fourmi Immo.
Including original code Copyright (c) 2011 Luc Donnet (Dryade), Pirmin Kalberer (Sourcepole) and others.
