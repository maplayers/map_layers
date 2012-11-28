// simple handler
var MapLayers = {};
MapLayers.SimpleMapHandler = function(map) {
  this.map = map;
  this.controls = {};
  this.dragCallbacks = {};

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

  this.toggleLayerFeaturePopup = function(layer, feature_id) {
    feature = this.getLayerFeatureById(layer, feature_id);
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

  this.getLayerFeatureById = function(layerName, feature_id) {
    var layer = this.map.getLayersByName(layerName)[0];
    var feature = null;

    for(fid in layer.features)
    {
      feat = layer.features[fid];
      if (feat.data.id == feature_id)
      {
        feature = feat;
        break;
      }
    }

    return feature;
  }

  this.setCenterOnFeature = function(feature, zoom) {
    zoom = ((zoom >= 3) && (zoom <= 18)) ? zoom : 5;
    if (feature != null)
    {
      var lonLat = feature.geometry.bounds.getCenterLonLat();
      if (lonLat) { this.map.setCenter(lonLat, zoom); }
    }
  }

  this.setCenterOnFeatureByNb = function(layerName, feature_nb, zoom) {
    var layer = this.map.getLayersByName(layerName)[0];
    var feature = layer.features[feature_nb];

    this.setCenterOnFeature(feature, zoom);
  }

  this.setDragCallback = function(evt, method) {
    switch (evt) {
    case 'onEnter':
    case 'onLeave':
    case 'onStart':
    case 'onComplete':
      this.dragCallbacks[evt] = method;
      break;
    default:
      alert('bad one');
      break;
    }
  }

  this.initializeControls = function(layerName) {
    var layer = this.map.getLayersByName(layerName)[0];
    var ctrls = {
      select : new OpenLayers.Control.SelectFeature(layer),
      point : new OpenLayers.Control.DrawFeature(layer, OpenLayers.Handler.Point),
      path : new OpenLayers.Control.DrawFeature(layer, OpenLayers.Handler.Path),
      polygon : new OpenLayers.Control.DrawFeature(layer, OpenLayers.Handler.Polygon),
      drag : new OpenLayers.Control.DragFeature(layer, {
        onComplete: function(feature) {
          if (this.dragCallbacks['onComplete'] !== undefined) { this.dragCallbacks['onComplete'](feature); }
        }.bind(this),
        onStart: function() {
          if (this.dragCallbacks['onStart'] !== undefined) { this.dragCallbacks['onStart'](feature); }
        },
        onDrag: function() {
          if (this.dragCallbacks['onDrag'] !== undefined) { this.dragCallbacks['onDrag'](feature); }
        }
      })
    }

    layer.events.on({
      featureselected: this.onFeatureSelect,
      featureunselected: this.onFeatureUnselect,
      scope : this
    });

    this.controls[layerName] = ctrls;

    for (var key in this.controls[layerName])
    {
      this.map.addControl(this.controls[layerName][key])
    }
  }

  this.toggleControl = function(layer, ctrl) {
    for(key in this.controls[layer])
    {
      if(ctrl == key) { this.controls[layer][key].activate(); }
      else { this.controls[layer][key].deactivate(); }
    }
  }

  this.addFeature = function(layerName, lon, lat, icon) {
    var layer = this.map.getLayersByName(layerName)[0];

    var lonlat = new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject());
    if (icon == null)
    {
      icon = { externalGraphic: "/assets/OpenLayers/marker.png",
               graphicWidth: 21,
               graphicHeight: 25,
               fillOpacity: 1
             };
    }

    var feature = new OpenLayers.Feature.Vector(
                      new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat), null, icon);
/*
    var feature = new OpenLayers.Feature.Vector(
                      new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat), null, {
                          //externalGraphic: "http://maps.google.com/mapfiles/kml/shapes/sunny.png",
                          externalGraphic: "/assets/OpenLayers/marker.png",
                          graphicWidth: 32,
                          graphicHeight: 32,
                          fillOpacity: 1
                      });
*/
    layer.addFeatures([feature]);
  }

  this.removeFeatures = function(layerName) {
    var layer = this.map.getLayersByName(layerName)[0];

    while (layer.features.length)
    {
      feat = layer.features[0];
      layer.removeFeatures(feat);
    }
  }

  this.destroyLayer = function(layerName) {
    var layer = this.map.getLayersByName(layerName)[0];

    // remove all popups
    while (this.map.popups.length) { this.map.removePopup(map.popups[0]); }

    // remove callbacks
    /*
    layer.events.on({
      featureselected: null,
      featureunselected: null,
      scope : this
    });
    */

    // desactivate all controls for this layer
    for(key in this.controls[layerName])
    {
      this.controls[layerName][key].deactivate();
      this.map.removeControl(this.controls[layerName][key]);
      this.controls[layerName][key].destroy();
      this.controls[layerName][key] = null;
    }

    this.map.removeLayer(layer);
    layer.destroy();
  }
};



// map_handler.addFeature('pikts', 8, 0);
// map_handler.setDragCallback('onComplete', function(feature) { lonlat = feature.geometry.getBounds().getCenterLonLat().transform(
//       map.getProjectionObject(),new OpenLayers.Projection("EPSG:4326")
//     ); $('#picture_latitude').val(lonlat.lat); $('#picture_longitude').val(lonlat.lon); });


// map_handler.addFeature('pikts', 50, 8, null);
// map_handler.addFeature('pikts', 5000, 8000, null);

// js :
// var point = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(-111.04, 45.68), {icon:"icon.png"});
// layer.addFeatures([point]); 
//
// var point = new OpenLayers.Geometry.Point(ll.lon, ll.lat);
// var feature = new OpenLayers.Feature.Vector(point,{icon:"icon.png"});
// layer.addFeature(feature);
//
//
// map_handler.setDragCallback('onComplete', function(feature) {
//   lonlat = feature.geometry.getBounds().getCenterLonLat().transform(map.getProjectionObject(),new OpenLayers.Projection("EPSG:4326"));
//   $('#picture_latitude').val(lonlat.lat);
//   $('#picture_longitude').val(lonlat.lon);
// });


// map_handler.setCenterOnFeature(map_handler.getLayerFeatureById('pikts', 'picture_44'), 3);
// map_handler.setDragCallback('onComplete', function (feat) { map_handler.setCenterOnFeature(feat, 5); });
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
