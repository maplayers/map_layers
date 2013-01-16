require 'test_helper'

describe MapLayers::ViewHelper do
  before do
    ActionView::Base.send(:include, MapLayers::ViewHelper)
    @view = ActionView::Base.new
  end

  it "should integrate with ActionView::Base" do
    [:map_layers_includes, :map_layers_script, :map_layers_container, :map_layers_localize_form_tag].each do |method|
      @view.respond_to?(method).must_equal true
    end
  end

  it "should accept block for map_layers_includes" do
    @map = MapLayers::JsExtension::MapBuilder.new('bigmap') do |builder, page|
      page << builder.map.add_layer(MapLayers::OpenLayers::GOOGLE)
      page << builder.map.zoom_to_max_extent()
    end

    mli = @view.map_layers_includes(@map, :onload => true) do
      "alert(%{map_handler});\nalert(%{map});".html_safe
    end

    html =<<EOS
<script src=\"http://maps.google.com/maps/api/js?v=3&amp;sensor=false\" type=\"text/javascript\"></script>
<script type=\"text/javascript\">
//<![CDATA[
OpenLayers.ImgPath='/assets/OpenLayers//';
var bigmap,bigmap_handler;
bigmap = null;
function map_layers_init_bigmap() {
if (bigmap == null) {
bigmap = new OpenLayers.Map('bigmap',{theme : false});
bigmap_handler = new OpenLayersHandlers.SimpleMapHandler(bigmap);
bigmap.addLayer(new OpenLayers.Layer.Google('Google Street',{sphericalMercator : true}));
bigmap.zoomToMaxExtent();
}
}
$(document).ready(function() { map_layers_init_bigmap(); });
alert(bigmap_handler);
alert(bigmap);
//]]>
</script>
EOS

    mli.must_equal html.strip
  end


end
