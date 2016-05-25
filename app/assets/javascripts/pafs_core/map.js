//define the osMap variable
var osMap;

function initMap() {
  if($('#map')){
    loadOSMap();
  }
}
function loadOSMap()
{

  var mapDiv = $('#map');
  var eastings = mapDiv.data('eastings'),
  northings = mapDiv.data('northings'),
  zoomLevel = mapDiv.data('zoomlevel'),
  marker = mapDiv.data('marker');

  osMap = new OpenSpace.Map('map', { controls: [ new OpenLayers.Control.TouchNavigation(
    { dragPanOptions: {enableKinetic: true } }) ]
  });
  var markerLayer = osMap.getMarkerLayer();

  osMap.getVectorLayer().styleMap.styles.select.defaultStyle.strokeWidth = 4;
  osMap.getVectorLayer().styleMap.styles.temporary.defaultStyle.strokeWidth = 4;
  osMap.getVectorLayer().styleMap.styles['default'].defaultStyle.strokeWidth = 4;
  var vlayer = osMap.getVectorLayer();
  var toolbar = new OpenLayers.Control.Panel({ displayClass:'olControlEditingToolbar'});

  toolbar.addControls([
    new OpenLayers.Control.Navigation(),
    new OpenLayers.Control.ModifyFeature(vlayer, {vertexRenderIntent: 'temporary',displayClass: 'olControlModifyFeature'}),
  ]);

  var polygons = mapDiv.data('polygons');

  createBenefitAreas(polygons, vlayer);

  if(typeof($('.location')[0]) !== 'undefined') {
    dragControl = new OpenSpace.Control.DragMarkers(markerLayer);
    osMap.addControl(dragControl);
    dragControl.activate();
    markerLayer.setDragMode(true);
    osMap.events.remove('dblclick');
    osMap.events.register("dblclick", this, this.addMarker);
  }

  if(typeof($('.benefit_area')[0]) !== 'undefined') {
    toolbar.addControls([
      new OpenLayers.Control.DrawFeature(vlayer, OpenLayers.Handler.Polygon, {displayClass: 'olControlDrawFeaturePolygon'}),
      new OpenLayers.Control.Button({ displayClass: "deleteButton", trigger: deleteFeature})
    ]);
  }

  osMap.addControls([toolbar, new OpenSpace.Control.SmallMapControl()]);
  osMap.setCenter(new OpenSpace.MapPoint(eastings, northings), zoomLevel);
  createInitialMarker(marker);
}

function createInitialMarker(marker) {
  var lon = parseFloat(marker[0]);
  var lat = parseFloat(marker[1]);
  var markerPoint = new OpenLayers.LonLat(lon, lat);
  osMap.createMarker(markerPoint);
}

function createBenefitAreas(polygons, vlayer) {
  polygons.forEach(function(polygon) {
    var points = [];

    polygon.forEach(function(point) {
      p = new OpenLayers.Geometry.Point(parseFloat(point[0]),parseFloat(point[1]));
      points.push(p);
    });

    var linearRing = new OpenLayers.Geometry.LinearRing(points);
    var polygonFeature = new OpenLayers.Feature.Vector(linearRing);

    vlayer.addFeatures([polygonFeature]);
  });
}

function report() {
  osMap.getControlsByClass("OpenLayers.Control.Button")[0].activate();
}

function deleteFeature() {
  if(osMap.getControlsByClass("OpenLayers.Control.ModifyFeature")[0].feature)

  {
    osMap.getControlsByClass("OpenLayers.Control.ModifyFeature")[0].feature.destroy();
    osMap.getControlsByClass("OpenLayers.Control.ModifyFeature")[0].deactivate();
    osMap.getControlsByClass("OpenLayers.Control.DrawFeature")[0].activate();
    osMap.getControlsByClass("OpenLayers.Control.DrawFeature")[0].deactivate();
    osMap.getControlsByClass("OpenLayers.Control.ModifyFeature")[0].activate();
  }

  osMap.getControlsByClass("OpenLayers.Control.Button")[0].deactivate();
}

function addMarker(evt) {
  osMap.clearMarkers();
  var posClick = osMap.getLonLatFromViewPortPx(evt.xy);
  console.log(posClick);
  osMap.createMarker(posClick);
  OpenLayers.Event.stop(evt);
}

function doNothing(evt) {
  OpenLayers.Event.stop(evt);
}

function dragStop() {
  markersLayer.setDragMode(false);
  dragControl.deactivate();
}

$(document).ready(initMap);
