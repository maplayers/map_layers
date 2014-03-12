/*
 *= require_self
 *= require_tree ./open_layers_handlers
 *= require openlayers-rails
*/

// declare namespace
var OpenLayersHandlers = {};

// TODO: add support for multiples map
function mapLayersLoading() {
  if (jQuery) { return mapLayersLoadingJquery(); }
  else { alert('jquery has to be loaded before map_layers') }
}

function mapLayersLoadingJquery() {
  return $('.map_container .loading');
}

function mapLayersLoadingShow() {
  mapLayersLoading().show();
}

function mapLayersLocalizeClick(e) {
  // avoid to link to be followed normally
  e.preventDefault();

  // geoloc form fields (lat, lng ...) container
  var map_info = $(this).parents('.map_info');

  // getting map container id
  var map = map_info.attr('data-map');

  // show map container
  $('#' + map).parent().show();

  // loading map
  eval('map_layers_init_' + map + '()');

  // collect localization fields (street, city, ...)
  var fields = new Array();
  map_info.find('.localize_me').each(function (idx, item) {
    fields.push($(item).val());
  });

  var layerName = $(this).attr('data-layer');

  $.ajax({
    url: this.href,
    data: {
      layer: layerName,
      map: map,
      search: fields.join(' ')
    }
  });

  mapLayersLoading().show();

  return false;
}

function mapLayersInitializer(){
  // add the loader indicator
  $('.map_layers.localize').off('submit', mapLayersLoadingShow);
  $('.map_layers.localize').on('submit', mapLayersLoadingShow);

  // localize
  $('.map_layers.localize_form_fields').off('click', mapLayersLocalizeClick);
  $('.map_layers.localize_form_fields').on('click', mapLayersLocalizeClick);

}

// Fill a form using OpenLayers
function mapLayersFillFormWithFeature(map_name, feature) {
  var map_for_form = eval(map_name);
  var lonlat = feature.geometry.getBounds().getCenterLonLat().clone().transform( map_for_form.getProjectionObject(),new OpenLayers.Projection("EPSG:4326") );
  mapLayersFillFormWithLonlat(map_name, lonlat.lat, lonlat.lon);
}
function mapLayersFillFormWithLonlat(map_name, lat, lon) {
  var form = $('.map_info[data-map="' + map_name + '"]');
  $(form).find('.latitude_field').val(lat);
  $(form).find('.longitude_field').val(lon);
}

// OPTIMIZE: remove jquery dependency
$(function() {
  mapLayersInitializer();
});
