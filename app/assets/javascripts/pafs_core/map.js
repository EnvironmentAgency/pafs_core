//define the osMap variable
var osMap;

//this function creates the map and is called by the div in the HTML

var init;

init = function()

  {

//create new map

    osMap = new OpenSpace.Map('#map');

//set map centre in National Grid Eastings and Northings and select zoom level 10

// Set map centre in National Grid Eastings and Northings and select zoom level 6

    osMap.setCenter(new OpenSpace.MapPoint(439000, 114000), 6);

// Create a new vector layer to hold the polygon

    var vectorLayer = new OpenLayers.Layer.Vector("Vector Layer");

    osMap.addLayer(vectorLayer);

// Create polygon style

    var style_green =
        {
            strokeColor: "#000000",
            strokeOpacity: 1,
            strokeWidth: 2,
            fillColor: "#00FF00",
            fillOpacity: 0.6
        };

// Define polygon area

    var p1 = new OpenLayers.Geometry.Point(439000, 114000);
    var p2 = new OpenLayers.Geometry.Point(440000, 115000);
    var p3 = new OpenLayers.Geometry.Point(437000, 116000);
    var p4 = new OpenLayers.Geometry.Point(436000, 115000);
    var p5 = new OpenLayers.Geometry.Point(436500, 113000);

    var points = [];
    points.push(p1);
    points.push(p2);
    points.push(p3);
    points.push(p4);
    points.push(p5);

// Create a polygon feature from the list of points

    var linearRing = new OpenLayers.Geometry.LinearRing(points);
    var polygonFeature = new OpenLayers.Feature.Vector(linearRing, null, style_green);

    vectorLayer.addFeatures([polygonFeature]);

  }


$(document).ready(ready);
$(document).on('page:load', ready);
