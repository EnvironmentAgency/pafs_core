var benefitAreaDetails, locationDetails;


locationDetails = function() {
  var locationInput = $('#location_step_project_location');
  var zoomLevelInput = $('#location_step_project_location_zoom_level');
  var location = osMap.markerLayer.markers[0].lonlat;
  var markerPoint = [Math.round(location.lon), Math.round(location.lat)];
  var zoomLevel = osMap.getZoom();

  locationInput.val(JSON.stringify(markerPoint));
  zoomLevelInput.val(zoomLevel);
}

benefitAreaDetails = function() {
  var paths = $('path');
  var polygons = $('polygon');
  var areasArray = [];
  var centrePoint = [];
  var areaInput = $('#map_step_benefit_area');
  var locationInput = $('#map_step_benefit_area_centre');
  var zoomLevelInput = $('#map_step_benefit_area_zoom_level');
  var zoomLevel = osMap.getZoom();


  if (typeof paths !== 'undefined') {
    paths = Array.from(paths);
    paths.forEach(function(path) {
      var pathCoords = [];

      path = path.attributes['d'].textContent;
      path = path.replace('M ','').replace(' z','').split(' ');

        path.forEach(function(element){
          pathCoords.push(element.split(',').map(Math.abs))
        });

      areasArray.push(pathCoords);
    });
  };

  if (typeof polygons !== 'undefined') {
    polygons = Array.from(polygons);
    polygons.forEach(function(polygon) {
      points = polygon.getAttribute('points').split(',').map(Math.abs);
      polygonPoints = [];

      points.forEach(function(point) {
        pointIndex = points.indexOf(point);
        if (pointIndex % 2 === 0) {
          polygonPoints.push([point, points[ pointIndex + 1]]);
        }
      });

      areasArray.push(polygonPoints);
    });
  }

  zoomLevelInput.val(JSON.stringify(zoomLevel));

  var centrePoint = osMap.getCenter();
  centrePoint = [Math.round(centrePoint.lon), Math.round(centrePoint.lat)]
  locationInput.val(JSON.stringify(centrePoint));

  areaInput.val(JSON.stringify(areasArray));
}

function addBenefitAreaDetails() {
  $('.edit_map_step').submit(benefitAreaDetails);
}

function addLocationDetails() {
  $('.edit_location_step').submit(locationDetails);
}

$(document).ready(addLocationDetails);
$(document).on('page:load', addLocationDetails);
$(document).ready(addBenefitAreaDetails);
$(document).on('page:load', addBenefitAreaDetails);
