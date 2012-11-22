// simple handler for popup window
var MapLayers = {};
MapLayers.SimpleFeatureHandler = function(map, sel) {
  this.map = map;
  this.selectFeature = sel;

  this.onPopupClose = function(evt) {
    this.selectedFeature.unselectAll();
  }
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
        //null, true, this.onPopupClose
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

};

MapLayers.SimpleLayerHandler = function(map, layer) {
  this.map = map;
  this.layerName = layer;

  this.toggleLayer = function() {
    var layer = this.map.getLayersByName(this.layerName)[0];
    visible = layer.getVisibility();
    layer.setVisibility(!visible);
  }

  
}

// map.setCenter(new OpenLayers.LonLat(1, 50), 5);
// map.getLayersByName('pikts')[0].features[0]
// pikts_handler.addFeaturePopup(map.getLayersByName('pikts')[0].features[0])

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
