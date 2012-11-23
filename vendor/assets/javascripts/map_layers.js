// simple handler for popup window
var MapLayers = {};
MapLayers.SimpleFeatureHandler = function(map, sel) {
  this.map = map;

  this.onFeatureSelect = function(event) {
    //var feature = event.feature;
    //alert("this " + this.constructor);
    this.addFeaturePopup(event.feature);
  }
  this.onFeatureUnselect = function(event) {
    this.removeFeaturePopup(event.feature);
  }

  this.addFeaturePopup = function(feature) {
    this.selectedFeature = feature;
    var popup = new OpenLayers.Popup.FramedCloud("chicken", 
        feature.geometry.getBounds().getCenterLonLat(),
        new OpenLayers.Size(100,100),
        "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description,
        null, false, null
    );
    feature.popup = popup;
    this.map.addPopup(popup);
  }

  this.removeFeaturePopup = function(feature) {
    if(feature.popup) {
      this.map.removePopup(feature.popup);
      feature.popup.destroy();
      delete feature.popup;
    }
  }

  this.toggleFeaturePopup = function(feature) {
    if(feature.popup) { this.removeFeaturePopup(feature); }
    else { this.addFeaturePopup(feature); }
  }

  this.toggleLayerFeaturePopup = function(layer, feature_nb) {
    feature = this.getLayerFeature(layer, feature_nb);
    this.toggleFeaturePopup(feature);
  }

  this.toggleLayer = function(layerName) {
    var layer = this.map.getLayersByName(layerName)[0];
    visible = layer.getVisibility();
    layer.setVisibility(!visible);
  }

  this.getLayerFeature = function(layerName, feature_nb) {
    var layer = this.map.getLayersByName(layerName)[0];
    var feature = layer.features[feature_nb];
    return feature;
  }

  this.setCenterOnFeature = function(layerName, feature_nb, zoom) {
    zoom = zoom || 5
    var layer = this.map.getLayersByName(layerName)[0];
    var lonLat = layer.features[feature_nb].geometry.bounds.centerLonLat

    if (lonLat)
    {
      this.map.setCenter(lonLat, zoom);
    }
  }
};

MapLayers.SimpleMapHandler = function(map) {
  this.map = map;


  
}

// map.setCenter(new OpenLayers.LonLat(1, 50), 5);
// map.getLayersByName('pikts')[0].features[0]
// pikts_handler.addFeaturePopup(map.getLayersByName('pikts')[0].features[0])
// map.setCenter(map.getLayersByName('pikts2')[0].features[0].geometry.bounds.centerLonLat, 5)
//
// movestart, move, moveend, zoomend
// map.events.register("moveend", map, function() {
//            alert("panning");
//        });

/*
var MapLayers = {};
MapLayers.SimpleFeatureHandler = function(map, sel) {
  this.map = map;
  this.selectFeature = sel;

  this.onPopupClose = function(evt) {
    this.selectedFeature.unselectAll();
  }
  this.onFeatureSelect = function(event) {
    var feature = event.feature;
    var selectedFeature = feature;
    var popup = new OpenLayers.Popup.FramedCloud("chicken", 
        feature.geometry.getBounds().getCenterLonLat(),
        new OpenLayers.Size(100,100),
        "<h2>"+feature.attributes.name + "</h2>" + feature.attributes.description,
        null, true, this.onPopupClose
    );
    feature.popup = popup;
    this.map.addPopup(popup);
  }
  this.onFeatureUnselect = function(event) {
    var feature = event.feature;
    if(feature.popup) {
      this.map.removePopup(feature.popup);
      feature.popup.destroy();
      delete feature.popup;
    }
  }
};
*/
