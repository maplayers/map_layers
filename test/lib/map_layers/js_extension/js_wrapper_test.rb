require 'test_helper'

describe MapLayers::JsExtension::JsWrapper do
  describe ".javascriptify_method" do
    it "should return a js method" do
      MapLayers::JsExtension::JsWrapper::javascriptify_method("add_overlay_to_hello").must_equal "addOverlayToHello"
    end
  end

  describe ".javascriptify_variable" do
#    it "should return a javascript variable mapping object" do
#      map = MapLayers::JsExtension::Map.new("div")
#      MapLayers::JsExtension::JsWrapper::javascriptify_variable(map).must_equal map.to_javascript
#    end

    it "should return a javascript numeric variable" do
      MapLayers::JsExtension::JsWrapper::javascriptify_variable(123.4).must_equal "123.4"
    end

    it "should return a javascript array variable" do
      MapLayers::JsExtension::JsWrapper::javascriptify_variable([123.4,'a',[123.4,5]]).must_equal "[123.4,'a',[123.4,5]]"
    end

    it "should return a javascript hash variable" do
      test_str = MapLayers::JsExtension::JsWrapper::javascriptify_variable("hello" => "world", "chopotopoto" => [123.55, 3], :symb => :ole)
      test_str.must_equal "{hello : 'world',chopotopoto : [123.55,3],symb : ole}"
    end
  end

#  describe ".declare" do
#    it "should declare a latlng variable" do
#      point = MapLayers::OpenLayers::LonLat.new(123.4,123.6)
#      point.declare("point").must_equal "var point = new OpenLayers.LonLat(123.4,123.6);"
#      point.variable.must_equal "point"
#    end
#  end
end

describe MapLayers::JsExtension::JsVar do
  it "should test array indexing" do
    obj = MapLayers::JsExtension::JsVar.new('obj')
    obj[0].variable.must_equal "obj[0]"
  end
end

describe MapLayers::JsExtension::JsGenerator do

  it "should test js generator" do
    js = MapLayers::JsExtension::JsGenerator.new
    @markers = MapLayers::JsExtension::JsVar.new('markers')
    js.assign('markers', MapLayers::OpenLayers::Layer::Markers.new('Markers'))
    js.assign('size', MapLayers::OpenLayers::Size.new(10,17))
    js.assign('offset', MapLayers::OpenLayers::Pixel.new(MapLayers::JsExtension::JsExpr.new("-(size.w/2), -size.h")))
    js.assign('icon', MapLayers::OpenLayers::Icon.new('http://boston.openguides.org/markers/AQUA.png',:size,:offset))
    js << @markers.add_marker(MapLayers::OpenLayers::Marker.new(MapLayers::OpenLayers::LonLat.new(0,0),:icon))
    html =<<EOS
markers = new OpenLayers.Layer.Markers('Markers');
size = new OpenLayers.Size(10,17);
offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
icon = new OpenLayers.Icon('http://boston.openguides.org/markers/AQUA.png',size,offset);
markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(0,0),icon));
EOS
    js.to_s.must_equal html.strip
  end

#  it "should test google example" do
#    @map = MapLayers::JsExtension::Map.new("map") do |map, page|
#      page << map.add_layer(MapLayers::JsExtension::GOOGLE)
#      page << map.zoom_to_max_extent()
#    end
#    html =<<EOS
#<script defer="defer" type="text/javascript">
#var map;
#map = new OpenLayers.Map('map', {theme : false});
#map.addLayer(new OpenLayers.Layer.Google("Google Street"));
#map.zoomToMaxExtent();
#</script>
#EOS
#    @map.to_html.should == html
#  end
#
#  it "should test kml example" do
#    @map = MapLayers::JsExtension::Map.new("map") do |map,page|
#      page << map.add_layer(OpenLayers::Layer::GML.new("Places KML", "/places/kml", {:format=> MapLayers::JsExtension::JsExpr.new("OpenLayers.Format.KML")}))
#    end
#    html =<<EOS
#<script defer="defer" type="text/javascript">
#var map;
#map = new OpenLayers.Map('map', {theme : false});
#map.addLayer(new OpenLayers.Layer.GML("Places KML","/places/kml",{format : OpenLayers.Format.KML}));
#</script>
#EOS
#    @map.to_html.should == html
#  end

end
