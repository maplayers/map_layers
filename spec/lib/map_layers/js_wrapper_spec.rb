require 'spec_helper'

describe MapLayers::JsWrapper do

  describe ".javascriptify_method" do
    it "should return a js method" do
      MapLayers::JsWrapper::javascriptify_method("add_overlay_to_hello").should == "addOverlayToHello"
    end
  end

  describe ".javascriptify_variable" do
    
    it "should return a javascript variable mapping object" do
      map = MapLayers::Map.new("div")
      MapLayers::JsWrapper::javascriptify_variable(map).should == map.to_javascript
    end

    it "should return a javascript numeric variable" do                                           
      MapLayers::JsWrapper::javascriptify_variable(123.4).should == "123.4"
    end

    it "should return a javascript array variable" do                                           
      map = MapLayers::Map.new("div")
      MapLayers::JsWrapper::javascriptify_variable([123.4,map,[123.4,map]]).should == "[123.4,#{map.to_javascript},[123.4,#{map.to_javascript}]]"
    end

    it "should return a javascript hash variable" do     
      map = MapLayers::Map.new("div")
      test_str = MapLayers::JsWrapper::javascriptify_variable("hello" => map, "chopotopoto" => [123.55,map])
      test_str.should == "{hello : #{map.to_javascript},chopotopoto : [123.55,#{map.to_javascript}]}" 
    end
  end

  describe ".declare" do
    it "should declare a latlng variable" do     
      point = OpenLayers::LonLat.new(123.4,123.6)
      point.declare("point").should == "var point = new OpenLayers.LonLat(123.4,123.6);"
      point.variable.should == "point" 
    end

  end

end

describe MapLayers::JsVar do

  it "should test array indexing" do     
    obj = MapLayers::JsVar.new("obj")
    obj[0].variable.should == "obj[0]"
  end

end

describe MapLayers::JsGenerator do

  it "should test js generator" do     
    @map = MapLayers::Map.new("map")
    js = MapLayers::JsGenerator.new
    js.assign("markers", OpenLayers::Layer::Markers.new('Markers'))
    @markers = MapLayers::JsVar.new('markers')
    js << @map.addLayer(@markers)
    js.assign("size", OpenLayers::Size.new(10,17))
    js.assign("offset", OpenLayers::Pixel.new(MapLayers::JsExpr.new("-(size.w/2), -size.h")))
    js.assign("icon", OpenLayers::Icon.new('http://boston.openguides.org/markers/AQUA.png',:size,:offset))
    js << @markers.add_marker(OpenLayers::Marker.new(OpenLayers::LonLat.new(0,0),:icon))
    html =<<EOS
markers = new OpenLayers.Layer.Markers("Markers");
map.addLayer(markers);
size = new OpenLayers.Size(10,17);
offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
icon = new OpenLayers.Icon("http://boston.openguides.org/markers/AQUA.png",size,offset);
markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(0,0),icon));
EOS
    js.to_s.should == html
  end

  it "should test google example" do     
    @map = MapLayers::Map.new("map") do |map, page|
      page << map.add_layer(MapLayers::GOOGLE)
      page << map.zoom_to_max_extent()
    end
    html =<<EOS
<script defer="defer" type="text/javascript">
var map;
map = new OpenLayers.Map('map', {theme : false});
map.addLayer(new OpenLayers.Layer.Google("Google Street"));
map.zoomToMaxExtent();
</script>
EOS
    @map.to_html.should == html
  end

  it "should test wms example" do    
    @map = MapLayers::Map.new("map") do |map,page|
      page << map.add_control(OpenLayers::Control::LayerSwitcher.new)
      page << map.add_layer(OpenLayers::Layer::WMS.new( "OpenLayers WMS",
          "http://labs.metacarta.com/wms/vmap0", {:layers => 'basic'} ))
      page << map.zoom_to_max_extent()
    end
    html =<<EOS
<script defer="defer" type="text/javascript">
var map;
map = new OpenLayers.Map('map', {theme : false});
map.addControl(new OpenLayers.Control.LayerSwitcher());
map.addLayer(new OpenLayers.Layer.WMS("OpenLayers WMS","http://labs.metacarta.com/wms/vmap0",{layers : "basic"}));
map.zoomToMaxExtent();
</script>
EOS
    @map.to_html.should == html
  end

  it "should test kml example" do    
    @map = MapLayers::Map.new("map") do |map,page|
      page << map.add_layer(OpenLayers::Layer::GML.new("Places KML", "/places/kml", {:format=> MapLayers::JsExpr.new("OpenLayers.Format.KML")}))
    end
    html =<<EOS
<script defer="defer" type="text/javascript">
var map;
map = new OpenLayers.Map('map', {theme : false});
map.addLayer(new OpenLayers.Layer.GML("Places KML","/places/kml",{format : OpenLayers.Format.KML}));
</script>
EOS
    @map.to_html.should == html
  end

  it "should test wfs example" do    
    @map = MapLayers::Map.new("map_div") do |map, page|
      page << map.add_layer(OpenLayers::Layer::WFS.new("Places WFS", "/places/wfs", {:typename => "places"}, {:featureClass => MapLayers::JsExpr.new("OpenLayers.Feature.WFS")}))
    end
    html =<<EOS
<script defer="defer" type="text/javascript">
var map_div;
map_div = new OpenLayers.Map('map_div', {theme : false});
map_div.addLayer(new OpenLayers.Layer.WFS("Places WFS","/places/wfs",{typename : "places"},{featureClass : OpenLayers.Feature.WFS}));
</script>
EOS
    @map.to_html.should == html
  end
  
end
