// we can check this flag to see if the data is loaded
let loaded = false;

// this will hold the data
let sessions;

// we can plug these into the map() function
// to plot the timeline
let minYear;
let maxYear;


let leftEdge;
let rightEdge;


function setup() {
  createCanvas(1280, 720);

  leftEdge = 100;
  rightEdge = width - 100;

  // see the handleLoad function below for what we do with the data
  loadJSON("Dataset_1_OurWorld.json", dataLoaded);
  // loadJSON("Dataset_2_Broyles.json", dataLoaded);
}


function draw() {
  background(60, 63, 108);
  fill(255);

  // if the data is not loaded, don't try to draw it
  if (loaded) {
    drawSessions();
  } else {
    textAlign(CENTER, CENTER);
    text("Loading " + frameCount, width/2, height/2);
  }
}


function drawSessions() {
  stroke(255);
  for (let i = 0; i < sessions.length; i++) {
    let d = sessions[i].Year;
    let x = map(d, minYear, maxYear, leftEdge, rightEdge);
    line(x, 100, x, 110);
  }
  noStroke();
  textAlign(LEFT, TOP);
  text("Years", 40, 99);
  noLoop();
}


function dataLoaded(data) {
  // keep track of the sessions
  sessions = data;

  // set the min date to a value higher than anything in our data
  minYear = sessions[0].Year;
  maxYear = sessions[0].Year;    
  for (let i = 1; i < sessions.length; i++) {
    let d = sessions[i].Year;
    if (d < minYear) {
      minYear = d;
    }
    if (d > maxYear) {
      maxYear = d;
    }
  }
  loaded = true;
}
