// Define a list of tile options
let tiles_library = {
    osm:{url:'http://{s}.tile.osm.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'},
    stamen_toner:{url:'https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://maps.stamen.com/">Stamen Design</a>'},
    stamen_terrain:{url:'https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://maps.stamen.com/">Stamen Design</a>'},
    stamen_watercolor:{url:'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://maps.stamen.com/">Stamen Design</a>'},	
  }
  
  function plotRoute(route, closed = false, points = false) {
    if (route.length > 0) {
      beginShape()
      for (let i = 0; i < route.length; i++) {
        pos = myMap.latLngToPixel(route[i].lat, route[i].lng)
        vertex(pos.x, pos.y)
        if (points)
          circle(pos.x, pos.y, 5)
      }
      closed ? endShape(CLOSE) : endShape()
    }
  }
  
  
  
  
  function plotText(txt, coord, xoffs=0, yoffs=0, angle=0) {
    push()
    angleMode(DEGREES)
    pos = myMap.latLngToPixel(coord.lat, coord.lng) 
    translate(pos.x, pos.y)
    rotate(angle)
    text(txt, 0+xoffs,0+yoffs)
    pop()
  }