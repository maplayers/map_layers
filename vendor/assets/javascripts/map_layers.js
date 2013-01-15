/*
 *= require_self
 *= require_tree ./open_layers_handlers
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

// add the loader indicator
$(function() {
  $('.map_layers.localize').submit(function(){
    mapLayersLoading().show();
  });
});

