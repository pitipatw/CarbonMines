// we can check this flag to see if the data is loaded
let loaded = false;

// this will hold the data
let sessions;

let sessionX; 
let sessionY;

let selectedIndex = 0;

// we can plug these into the map() function
// to plot the timeline
let minYear;
let maxYear;

let minCarbon = 0;
let maxCarbon;


let leftEdge;
let rightEdge;

// console.log()

function setup() {
  createCanvas(1280, 720);

  leftEdge = 100;
  rightEdge = width - 100;

  // see the handleLoad function below for what we do with the data
  loadJSON("Dataset_1_OurWorld.json", dataLoaded);
  loadJSON("US.json", loadMap);
  // loadJSON("Dataset_2_Broyles.json", dataLoaded);
}


function draw() {
  background(60, 63, 108);
  fill(255);
  // if the data is not loaded, don't try to draw it
  if (loaded) {
    // text(str(maxCarbon), 100,100)
    drawSessions();
  } else {
    textAlign(CENTER, CENTER);
    text("Loading " + frameCount, width/2, height/2);
  }
}


function drawSessions() {
  stroke(255);
  // fill(100,100,100)
  for (let i = 0; i < sessions.length; i++) {
    let d = sessions[i].Year;
    let c = sessions[i].Carbon
    let x = map(d, minYear, maxYear, leftEdge, rightEdge);
    let y = height - map(c, minCarbon, maxCarbon, leftEdge, rightEdge)
    circle(x,y,1)
    // line(x, 100, x, 110);
  }

  let sx = sessionX[selectedIndex]; 

  let carbon = sessions[selectedIndex].Carbon;
  let country = sessions[selectedIndex].Entity;

  textAlign(LEFT,TOP)
  text(carbon, sx-6, 84)
  textAlign(LEFT, BOTTOM)
  text(country, sx+6, 84)



  noStroke();
  textAlign(LEFT, TOP);
  text("Years", width/2 , height-75);
  noLoop();
}

function loadMap(data){ 
  mapdata = data
  maploaded = true 
}
function dataLoaded(data) {
  // keep track of the sessions
  sessions = data;

  // set the min date to a value higher than anything in our data
  minYear = sessions[0].Year;
  maxYear = sessions[0].Year;    
  maxCarbon = sessions[0].Carbon
  for (let i = 1; i < sessions.length; i++) {
    let d = sessions[i].Year;
    let c = sessions[i].Carbon;

    if (d < minYear) {
      minYear = d;
    }
    if (d > maxYear) {
      maxYear = d;
    }

    if (c > maxCarbon) {
      maxCarbon = c
    }
  }
  loaded = true;
}


function mouseMOved() { 
  let closestDistance = width *2 ; 
  let distance ; 

  for (let i = 0 ; i <sessionX.length;  i++) {
    let x = sessionX[i]
    distance = abs(mouseX - x) 
    if (distance < closestDistance) { 
      closestDistance = distance; 
      selectedIndex = i;
    }
  }
  loop();
}
