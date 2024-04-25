// Define variables for holding our canvas and maps
let myMap
let canvas
const mappa = new Mappa('Leaflet')
let coords_text

// Define points of interest
let london = {lat:51.5074, lng:-0.1278}

let elephant_tree = {lat:51.5168, lng:-0.3093}

// Set up the options for our map
const options = {
  lat: london.lat,
  lng: london.lng,
  zoom: 10,
  style: tiles_library.osm.url
}

function preload() {
  geodata = loadJSON('US.json');
  //geodata = loadJSON('europe.geo.json')
}

function setup(){
  // Create a canvas on which to draw the map
  canvas = createCanvas(640,640)

  // Create map with the options
  myMap = mappa.tileMap(options)

  // Draw the map on the canvas
  myMap.overlay(canvas)
  

  
 // print(london.features[0].geometry.coordinates[0])
  //print(london.features[0].properties.name)
  //polygons = myMap.geoJSON(geodata, 'Polygon')
  //names = geoJsonNames(geodata)
  
  polygons = myMap.geoJSON(geodata, 'MultiPolygon')
  names = geoJsonNames(geodata)  
  
  
//  print(names)
//  print(polygons)

  
}

function geoJsonNames(data) {
  names = []
  for (let i = 0; i < data.features.length; i++) {
    names.push(data.features[i].properties.name)
  }
  return names
}

function geoPlotPolygon(data, index) {
  let polygon = data[index][0]
  if (polygon.length > 0) {
    beginShape()
    for (let i = 0; i < polygon.length; i++) {
      pos = myMap.latLngToPixel(polygon[i][1], polygon[i][0])
      //print(pos)
      vertex(pos.x, pos.y)
    }
    endShape(CLOSE)
  }
}

function geoPlotMultiPolygon(data, index) {
  let polygons = data[index][0]
  for (let p=0; p<polygons.length; p++) {
    let polygon = polygons[p]
    if (polygon.length > 0) {
      beginShape()
      for (let i = 0; i < polygon.length; i++) {
        pos = myMap.latLngToPixel(polygon[i][1], polygon[i][0])
        //print(pos)
        vertex(pos.x, pos.y)
      }
      endShape(CLOSE)
    }
  }
}

function draw(){
   // Clear the canvas on every frame
  clear()
  
    stroke("green")
  strokeWeight(5)
  noFill()
  //route = geodata.features[0].geometry.coordinates[0][0]
  
  route = polygons//geodata.features[0].geometry.coordinates[0]
  //print(route)
  //print(route)
  geoPlotMultiPolygon(polygons, 0)    
}

