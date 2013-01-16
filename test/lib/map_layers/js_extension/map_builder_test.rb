require 'test_helper'

describe MapLayers::JsExtension::JsWrapper do

  it 'should add google layer' do
    @map = MapLayers::JsExtension::MapBuilder.new('map') do |builder, page|
      page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE)
      page << builder.map.zoom_to_max_extent()
    end
    html =<<EOS
var map,map_handler;
map = null;
function map_layers_init_map() {
if (map == null) {
map = new OpenLayers.Map('map',{theme : false});
map_handler = new OpenLayersHandlers.SimpleMapHandler(map);
map.addLayer(new OpenLayers.Layer.Google('Google Street',{sphericalMercator : true}));
map.zoomToMaxExtent();
}
}
EOS
    @map.to_js.must_equal html.strip
  end

  it 'should have ajax mode without init' do
    @map = MapLayers::JsExtension::MapBuilder.new('map', :no_init => true) do |builder, page|
      page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE)
      page << builder.map.zoom_to_max_extent()
    end
    html =<<EOS
map.addLayer(new OpenLayers.Layer.Google('Google Street',{sphericalMercator : true}));
map.zoomToMaxExtent();
EOS
    @map.to_js.must_equal html.strip
  end

  it 'should add all features for complex builder' do
    @map = MapLayers::JsExtension::MapBuilder.new('bigmap') do |builder, page|
      page << builder.map.add_layer(MapLayers::OpenLayers::OSM_MAPNIK)
      page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE)

      page << builder.map.add_control(MapLayers::OpenLayers::Control::LayerSwitcher.new)
      page << builder.map.add_control(MapLayers::OpenLayers::Control::Permalink.new('permalink'))
      page << builder.map.add_control(MapLayers::OpenLayers::Control::MousePosition.new)

      page << builder.add_vector_layer('pikts', '/pictures.kml', :format => :kml, :default_control => 'select')

      page << builder.map_handler.initialize_controls('pikts')
      page << builder.map_handler.toggle_control('pikts', 'select')

      page << builder.map.zoom_to_max_extent()
    end
    html =<<EOS
var bigmap,pikts,bigmap_handler;
bigmap = null;
function map_layers_init_bigmap() {
if (bigmap == null) {
bigmap = new OpenLayers.Map('bigmap',{theme : false});
bigmap_handler = new OpenLayersHandlers.SimpleMapHandler(bigmap);
bigmap.addLayer(new OpenLayers.Layer.OSM('OpenStreetMap'));
bigmap.addLayer(new OpenLayers.Layer.Google('Google Street',{sphericalMercator : true}));
bigmap.addControl(new OpenLayers.Control.LayerSwitcher());
bigmap.addControl(new OpenLayers.Control.Permalink('permalink'));
bigmap.addControl(new OpenLayers.Control.MousePosition());
pikts = new OpenLayers.Layer.Vector('pikts',{projection : bigmap.displayProjection,strategies : [new OpenLayers.Strategy.Fixed()],protocol : new OpenLayers.Protocol.HTTP({url : '/pictures.kml',format : new OpenLayers.Format.KML({extractStyles : true,extractAttributes : true})})});
bigmap.addLayer(pikts);
bigmap_handler.initializeControls('pikts');
bigmap_handler.toggleControl('pikts','select');
bigmap.zoomToMaxExtent();
}
}
EOS
    @map.to_js.must_equal html.strip
  end

end
