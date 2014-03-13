// simple map handler
OpenLayersHandlers.SimpleMapHandler = function(map) {
  this.map = map;
  this.controls = {};
  this.dragCallbacks = {};

  /**
   * Method: ajaxPopupContent
   * Check whether or not ajax content has been defined for a feature popup.
   *
   * Parameters:
   * feature - {feature} The feature to check.
   */
  this.ajaxPopupContent = function(feature) {
    return (feature.attributes.popupContentUrl !== undefined);
  }

  /**
   * Method: addFeaturePopupContent
   * Add static content for popup.
   *
   * Parameters:
   * feature - {feature} The feature where popup is requested.
   * popup - {popup} useless ?
   */
  this.addFeaturePopupContent = function(feature, popup) {
    name = feature.attributes.name;
    url = feature.attributes.popupContentUrl;

    if (url !== undefined)
    {
      var request = OpenLayers.Request.GET({
          url: url,
          scope: feature,
          callback: function(request) {
            this.attributes.popup_content = request.responseText;

            // update popup content
            var popup_el = document.getElementById(this.attributes.id);
            popup_el.querySelector('.map_layer_popup').innerHTML = this.attributes.popup_content;

            this.popup.updateSize();
          }
      });
    }
    else
    {
      if (feature.attributes.link !== undefined)
      {
        name = '<a href="' + feature.attributes.link + '">' + name + '</a>';
      }
      feature.attributes.popup_content = '<h2>' + name + '</h2>' + feature.attributes.description;
    }
  }

  /**
   * APIMethod: addFeaturePopup
   * Open popup on feature.
   *
   * Parameters:
   * feature - {feature} The feature where popup should be opened.
   */
  this.addFeaturePopup = function(feature) {
    this.selectedFeature = feature;

    if (!this.ajaxPopupContent(feature))
    {
      // adding static content
      this.addFeaturePopupContent(feature);
      pop_content = feature.attributes.popup_content;
    }
    else
    {
      // initialize empty popup for ajax
      pop_content = '';
    }


    pop_container = '<div class="map_layer_popup">' + pop_content + '</div>';

    var popup = new OpenLayers.Popup.FramedCloud(feature.attributes.id,
        feature.geometry.getBounds().getCenterLonLat(),
        new OpenLayers.Size(100,100),
        pop_container,
        null, false, null
    );
    //popup.autoSize = true; // doesn't work on stable release
    popup.border = 0; // doesn't work on stable release
    feature.popup = popup;
    this.map.addPopup(popup);

    // adding ajax content if needed
    if (this.ajaxPopupContent(feature))
    {
      this.addFeaturePopupContent(feature);
    }
  }

  /**
   * APIMethod: removeFeaturePopup
   * Close popup on feature.
   *
   * Parameters:
   * feature - {feature} The feature where popup should be closed.
   */
  this.removeFeaturePopup = function(feature) {
    if(feature.popup) {
      this.map.removePopup(feature.popup);
      feature.popup.destroy();
      delete feature.popup;
    }
  }

  /**
   * APIMethod: toggleFeaturePopup
   * Toggle popup on feature.
   *
   * Parameters:
   * feature - {feature} The feature where popup should be opened or closed.
   */
  this.toggleFeaturePopup = function(feature) {
    if(feature.popup) { this.removeFeaturePopup(feature); }
    else { this.addFeaturePopup(feature); }
  }

  /**
   * APIMethod: toggleLayerFeaturePopup
   * Toggle popup on feature by layer and feature number.
   *
   * Parameters:
   * layer - {layer} The layer containing the requested feature.
   * feature_id - {number} The feature number to toggle.
   */
  this.toggleLayerFeaturePopup = function(layer, feature_id) {
    feature = this.getLayerFeatureById(layer, feature_id);
    this.toggleFeaturePopup(feature);
  }

  /**
   * APIMethod: toggleLayer
   * Toggle layer visibility from layer name.
   *
   * Parameters:
   * layerName - {string} The layer name to toggle.
   */
  this.toggleLayer = function(layerName) {
    var layer = this.map.getLayersByName(layerName)[0];
    visible = layer.getVisibility();
    layer.setVisibility(!visible);
  }

  this.getLayerFeatureLength = function(layerName) {
    var layer = this.map.getLayersByName(layerName)[0];
    return layer.features.length;
  }

  /**
   * Method: getLayerFeatureByNb
   * Get feature from layer name and feature number.
   *
   * Parameters:
   * layerName - {string} The layer name where to search for feature.
   * feature_nb - {number} The feature number.
   */
  this.getLayerFeatureByNb = function(layerName, feature_nb) {
    var layer = this.map.getLayersByName(layerName)[0];
    var feature = feature_nb != -1 ? layer.features[feature_nb] : layer.features.slice(-1).pop();
    return feature;
  }

  /**
   * Method: getLayerFeatureById
   * Get feature from layer name and feature id.
   *
   * Parameters:
   * layerName - {string} The layer name where to search for feature.
   * feature_id - {number} The feature id.
   */
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

  /**
   * APIMethod: getLonlatFromCoordinates
   * Get lonlat from latitude and longitude.
   *
   * Parameters:
   * lat - {float} Latitude.
   * lon - {float} Longitude.
   */
  this.getLonlatFromCoordinates = function(lat, lon) {
    var lonlat = new OpenLayers.LonLat(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject());
    return lonlat;
  }

  /**
   * APIMethod: setCenterOnLonlat
   * Set map center on lonlat at specified zoom level.
   *
   * Parameters:
   * lonlat - {LonLat} Lonlat object for coordinates.
   * zoom - {number} Zoom level.
   */
  this.setCenterOnLonlat = function(lonlat, zoom) {
    if (zoom === undefined) { zoom = this.map.getZoom(); }
    if (lonlat) { this.map.setCenter(lonlat, zoom); }
  }

  /**
   * APIMethod: setCenterOnCoordinates
   * Set map center on coordinates at specified zoom level.
   *
   * Parameters:
   * lat - {float} Latitude coordinate.
   * lon - {float} Longitude coordinate.
   * zoom - {number} Zoom level.
   */
  this.setCenterOnCoordinates = function(lat, lon, zoom) {
    var lonlat = this.getLonlatFromCoordinates(lat, lon);
    this.setCenterOnLonlat(lonlat, zoom);
  }

  /**
   * APIMethod: setCenterOnFeature
   * Set map center on feature at specified zoom level.
   *
   * Parameters:
   * feature - {feature} Feature to center on.
   * zoom - {number} Zoom level.
   */
  this.setCenterOnFeature = function(feature, zoom) {
    if (feature != null)
    {
      if (feature.geometry.bounds == null)
      {
        feature.geometry.calculateBounds();
      }
      var lonlat = feature.geometry.bounds.getCenterLonLat().clone();
      this.setCenterOnLonlat(lonlat, zoom);
    }
  }

  /**
   * APIMethod: setCenterOnFeatureByNb
   * Set map center on feature at specified zoom level.
   *
   * Parameters:
   * layerName - {string} The layer name where to search for feature.
   * feature_nb - {number} The feature number.
   * zoom - {number} Zoom level.
   */
  this.setCenterOnFeatureByNb = function(layerName, feature_nb, zoom) {
    var feature = this.getLayerFeatureByNb(layerName, feature_nb)
    this.setCenterOnFeature(feature, zoom);
  }

  /**
   * APIMethod: setDragCallback
   * Handle callback for events.
   *
   * Parameters:
   * evt - {string} Event name.
   * method - {function} Function to bind on event.
   */
  this.setDragCallback = function(evt, method) {
    switch (evt) {
    case 'onEnter':
    case 'onLeave':
    case 'onStart':
    case 'onComplete':
      this.dragCallbacks[evt] = method;
      break;
    default:
      alert('bad callback name : ' + evt);
      break;
    }
  }

  /**
   * Method: onFeatureSelect
   * Callback function called on feature select.
   */
  this.onFeatureSelect = function(event) {
    this.addFeaturePopup(event.feature);
  }

  /**
   * Method: onFeatureUnselect
   * Callback function called when feature is unselected.
   */
  this.onFeatureUnselect = function(event) {
    this.removeFeaturePopup(event.feature);
  }

  /**
   * APIMethod: initializeControls
   * Initialize base controls (Select, Draw, Drag) and bind to callbacks
   * functions.
   *
   * Parameters:
   * controlsName - {string} Control group name.
   * layersNames - {string/array} Layer/layers to use with this group of controls.
   */
  this.initializeControls = function(controlsName, layersNames) {
    // controlsName OR layers attribute
    var layers = new Array();

    // if layersNames is just a string, convert to array
    if (typeof(layersNames) == 'string') {
      layersNames = new Array(layersNames);
    }

    for (var idx in layersNames) {
      var layer_by_name = this.map.getLayersByName(layersNames[idx]);
      if (layer_by_name.length > 0) {
        layers.push(layer_by_name[0]);
      }
    }

    var select_obj = undefined;
    var point_obj = undefined;
    var path_obj = undefined;
    var polygon_obj = undefined;
    var drag_obj = undefined;

    if (OpenLayers.Control.SelectFeature) {
      select_obj = new OpenLayers.Control.SelectFeature(layers);
    }
    if (OpenLayers.Control.DrawFeature) {
      point_obj = new OpenLayers.Control.DrawFeature(layers[0], OpenLayers.Handler.Point);
      path_obj = new OpenLayers.Control.DrawFeature(layers[0], OpenLayers.Handler.Path);
      polygon_obj = new OpenLayers.Control.DrawFeature(layers[0], OpenLayers.Handler.Polygon);
    }
    if (OpenLayers.Control.DragFeature) {
      drag_obj = new OpenLayers.Control.DragFeature(layers[0], {
        onComplete: function(feature) {
          if (this.dragCallbacks['onComplete'] !== undefined) { this.dragCallbacks['onComplete'](feature); }
        }.bind(this),
        onStart: function() {
          if (this.dragCallbacks['onStart'] !== undefined) { this.dragCallbacks['onStart'](feature); }
        },
        onDrag: function() {
          if (this.dragCallbacks['onDrag'] !== undefined) { this.dragCallbacks['onDrag'](feature); }
        }
      });
    }

    var ctrls = {
      select : select_obj,
      point : point_obj,
      path : path_obj,
      polygon : polygon_obj,
      drag : drag_obj
    };

    for (var idx in layers) {
      var layer = layers[idx];
      layer.events.on({
        featureselected: this.onFeatureSelect,
        featureunselected: this.onFeatureUnselect,
        scope : this
      });
    }

    this.controls[controlsName] = ctrls;
    for (var key in this.controls[controlsName])
    {
      this.map.addControl(this.controls[controlsName][key])
    }
  }

  /**
   * APIMethod: switchControl
   * Select from base controls : Select, Draw or Drag
   *
   * Parameters:
   * controlsName - {string} Control group name.
   * ctrl - {string} Control type to use.
   */
  this.switchControl = function(controlsName, ctrl) {
    for(key in this.controls[controlsName])
    {
      var current_ctrl = this.controls[controlsName][key];
      if (current_ctrl !== undefined)
      {
        if (ctrl == key) { current_ctrl.activate(); }
        else { current_ctrl.deactivate(); }
      }
    }
  }

  /**
   * APIMethod: toggleControlObject
   * Activate/Deactivate control
   *
   * Parameters:
   * ctrl - {control} Control object to toggle.
   */
  this.toggleControlObject = function(ctrl) {
    var active = ctrl.active;
    if (ctrl.active == true)
      ctrl.deactivate && ctrl.deactivate();
    else
      ctrl.activate && ctrl.activate();
    return active;
  }

  /**
   * APIMethod: toggleControlByClass
   * Activate/Deactivate control for control class.
   *
   * Parameters:
   * klass - {string} Control class to toggle.
   */
  this.toggleControlByClass = function(klass) {
    var active = false;
    var handler = this;
    this.map.getControlsByClass(klass).forEach( function(entry) {
      active = handler.toggleControlObject(entry);
    });
    return active;
  }

  /**
   * APIMethod: toggleControls
   * Activate/Deactivate all controls.
   */
  this.toggleControls = function() {
    var active = false;

    for (var key in this.map.controls)
    {
      var current_ctrl = this.map.controls[key];
      active = this.toggleControlObject(current_ctrl);
    }

    return active;
  }

  /**
   * APIMethod: addFeature
   * Add a new feature on layer.
   *
   * Parameters:
   * layerName - {string} The layer name on which to add feature.
   * lat - {float} Latitude coordinate.
   * lon - {float} Longitude coordinate.
   * icon - {hash} additionnal feature parameters.
   */
  this.addFeature = function(layerName, lat, lon, icon) {
    var layer = this.map.getLayersByName(layerName)[0];

    var point = new OpenLayers.Geometry.Point(lon, lat).transform(new OpenLayers.Projection("EPSG:4326"), map.getProjectionObject());
    if (icon == null)
    {
      icon = { externalGraphic: "/assets/OpenLayers/marker.png",
               graphicWidth: 21,
               graphicHeight: 25,
               fillOpacity: 1
             };
    }

    var feature = new OpenLayers.Feature.Vector(point, null, icon);
    layer.addFeatures([feature]);
    return feature;
  }

  /**
   * APIMethod: addFeatureAttributes
   * Add attributes to feature.
   *
   * Parameters:
   * feature - {feature} Feature.
   * attributes - {hash} additionnal feature attributes.
   */
  this.addFeatureAttributes = function(feature, attributes) {
    if (feature != null)
    {
      for (var key in attributes) {
        feature.attributes[key] = attributes[key];
      }
    }
  }

  /**
   * APIMethod: removeFeatures
   * Remove all features from layer.
   *
   * Parameters:
   * layerName - {string} The layer name on which to remove features.
   */
  this.removeFeatures = function(layerName) {
    var layer = this.map.getLayersByName(layerName)[0];

    while (layer.features.length)
    {
      feat = layer.features[0];
      layer.removeFeatures(feat);
    }
  }

  /**
   * APIMethod: destroyLayer
   * Remove layer and associated objects.
   *
   * Parameters:
   * layerName - {string} The layer name to remove.
   */
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

    // destroy all controls for this layer
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

  /**
   * APIMethod: getMapCenter
   * Get map center coordinates.
   */
  this.getMapCenter = function() {
    var centerLonLat = this.map.getCenter().clone().transform( this.map.getProjectionObject(),new OpenLayers.Projection("EPSG:4326") );
    center = [centerLonLat.lat,centerLonLat.lon];
    return center;
  }
};
