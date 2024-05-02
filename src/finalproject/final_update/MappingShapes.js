let worldMap;

let infoPopupState = true;

let clickedState = "";
let clickedStateShape = "";
let oldClickedStateShape = "";
// let clickedStateId = ""; 
let carbon = [];
let currentColor = [];

let carboni;
let minCarbon = 10000;
let maxCarbon = 0;

// let loaded = false ;
let loaded = false;
let availableStates = [];


let mySelect;
let mySlider;

let carbonSlideVal = 0 ; 


let higherState = [];
let lowerState = [];

let higherCarbon = [];
let lowerCarbon = [];

// map value to color gradients in the range of 0 to 1. 
function myColor(value){
if (value <= 0){ //less than the selected state -> blue tone
  let to = color(255,0,0)
}
else{
  let to = color(218, 165, 32)
  }
baseColor = color(255,255,255)
col = lerbColor(baseColor, to, abs(value))
return col
}




function setup() {
  createCanvas(800, 480);
  background(224);

  // If you change the dimensions, the aspect ratio will stay the same.
  // The browser will size the map to use as much of the width/height as possible.
  let mapWidth = width * 0.75;  // use 80% of the sketch size
  let mapHeight = height * 0.75;
  // Center the map on the screen. The mapX and mapY
  // coordinates are relative to the sketch location.
  let mapX = 4 * (width - mapWidth) / 5;
  let mapY = (height - mapHeight) / 2;

  // let mapPath = "data/world-robinson.svg";
  //let mapPath = "data/world-equirectangular.svg";
  //let mapPath = "data/us-counties.svg";
  let mapPath = "data/us-states.svg";
  let stateCarbonPath = "data/statecarbon.json"


  // This will create a new SVG map from the 'robinson.svg' file in the data folder.
  // Once the map has finished loading, the mapReady() function will be called.
  worldMap = new SimpleSVG(mapPath, mapX, mapY, mapWidth, mapHeight, mapReady);
  //load the dataset
  stateCarbon = loadJSON(stateCarbonPath, dataLoaded)
}



function setupControls() {
  mySelect = createSelect();
  mySelect.position(width - 285, height - 50);
  mySelect.option("Check Nation-wide");
  mySelect.option("Check by States");
  mySelect.style('border-radius', '3px');
  mySelect.style('width', '150px');
  mySelect.style('padding', '0.5em');

  mySlider = createSlider(0, 700);
  mySlider.position(width / 2 - 200, height - 30)
  mySlider.size(300)

  myResetButton = createButton("RESET")
  myResetButton.position(width - 75, height - 40)
  myResetButton.mousePressed(reset)

  // myCheckbox1 = createCheckbox("Office");
  // myCheckbox2 = createCheckbox("Warehouse");
  // myCheckbox3 = createCheckbox("Residential");

  // myCheckbox1.position(width-100,height/2)
  // myCheckbox2.position(width-100,height/2-50)
  // myCheckbox3.position(width-100,height/2-100)

}

// this function is called when the map loads
function mapReady() {
  // show a list of all the shapes by name (i.e all the country codes)
  print(worldMap.listShapes());

  // call the function named 'mapClick' whenever a shape is clicked
  worldMap.onClick(mapClick);

  // handle mouseover (hover) events, and mouseout (the opposite of hover)
  worldMap.onMouseOver(mapOver);
  worldMap.onMouseOut(mapOut);

  setupControls()
  infoPopup()
}


//Load the data from the json file.
function dataLoaded(data) {
  sessions = data;
  for (let i = 1; i < sessions.length; i++) {
    availableStates.push(sessions[i].State)
    thisCarbon = sessions[i].Carbon
    carbon.push(thisCarbon)
    if (thisCarbon > maxCarbon) {
      maxCarbon = thisCarbon
    }

    if (thisCarbon < minCarbon) {
      minCarbon = thisCarbon
    }
    // print(sessions[i].State)
    worldMap.setFill(sessions[i].State, 'green');
  }
  loaded = true
}

function reset() {
  //when hit, turn every state to grey color, and clickedstate to ""
  for (let i = 1; i < sessions.length; i++) {
    state = sessions[i].State
    worldMap.setFill(sessions[i].State, 'green');
    clickedStateShape = ""
    clickedState = ""
    marked = []
  }
}

//Define what happen when click on the map.
function mapClick(shape) {
  //First, make sure that the element that clicked is not ignoorange.
  if (!ignoreShape(shape.id)) {
    // worldMap.setFill(shape, 'orange');
    //prevent error from the first run
    oldClickedStateShape = clickedStateShape

    //reset the color to normal (only 1 state can be clicked at a time)
    if (availableStates.includes(oldClickedStateShape.id)) {
      worldMap.setFill(oldClickedStateShape, 'green');
    }

    if (availableStates.includes(shape.id)) {
      clickedStateShape = shape
      worldMap.setFill(clickedStateShape, 'orange');
    }

    //compare carbon and highlight
    currentCarbon = carbon[availableStates.indexOf(clickedStateShape.id)]

    higherState = [];
    lowerState = [];

    higherCarbon = [];
    lowerCarbon = [];

    //loop one by one, if larger, push it to the right array with carbon.
    for (let i = 1; i < sessions.length; i++) {
      carboni = carbon[i]
      statei = sessions[i].State
      col = myColor(val)
      if (carboni >= currentCarbon) {
        if (statei != clickedStateShape.id) {
          marked.push(availableStates[i])
          // worldMap.setFill(availableStates[i], 'red');
          let val = carboni/currentCarbon
          
          worldMap.setFill(availableStates[i], 'red');

        }
        else{
          print(availableStates[i])
          worldMap.setFill(availableStates[i], 'green')
        }
      }

    }
    allStates = worldMap.listShapes()
  }

  //also update the table.
  
  print(`click ${shape.id}`);
}

function mapOver(shape) {
  //Make sure that it's not ignoorange.
  if (!ignoreShape(shape.id)) {
    //if it's the clickable state, put it in orange
    if (availableStates.includes(shape.id)) {
      worldMap.setFill(shape, 'orange')
    }
    //if it's the currently clicked, put it in darker orange.
    if (clickedStateShape.id == shape.id) {
      //dark read
      worldMap.setFill(shape, '#8B0000')
    }
    print(`over ${shape.id}`);
  }
}

function mapOut(shape) {
  //Make sure that it's not ignoorange.
  if (!ignoreShape(shape.id)) {
    //If it's the clicked state, put it in orange
    if (shape.id == clickedState){ 
      worldMap.setFill(shape, 'orange');
    }
    if (shape.id != clickedState){
      if (availableStates.includes(shape.id)) {
      worldMap.setFill(shape, 'green')
      }
    }
    //It it's the marked state, put it in red
    if (marked.includes(shape.id)){
      worldMap.setFill(shape, 'red');
    }
  }
  print(`out ${shape.id}`);
}


// returns 'true' if this shape should be ignoorange
// i.e. if it's the ocean or it's the boundary lines between states
function ignoreShape(name) {
  return (name === 'ocean' || name.startsWith('lines-'));
}

function colorMapByCarbon(value) {
  // again, have to loop each one and and compare, check
}

function tableStats(name) {
  push()
  let boxStartX = 20;
  let boxStartY = 75;
  let boxWidth = 120;
  let boxHeight = 75;
  let rowHeight = 20;
  let rowWidth = boxWidth;
  let ranki = "No data" ; //query the rank
  let carboni = "No data" ; //query the carbon

  if (availableStates.includes(name)){
    ranki = marked.length
    carboni = str(carbon[availableStates.indexOf(name)])
  }

  rect(boxStartX, boxStartY, boxWidth, boxHeight)
  line(boxStartX, boxStartY + rowHeight, boxStartX + rowWidth, boxStartY + rowHeight)
  fill(0)
  text("State:", boxStartX + 10, boxStartY + 0.75 * rowHeight)
  text(name, boxStartX + 50, boxStartY + 0.75 * rowHeight)

  text("Rank: " + ranki, boxStartX + 10, boxStartY + 0.75 * 3 * rowHeight)
  text("Carbon: " + carboni.substring(0,5), boxStartX + 10, boxStartY + 0.75 * 4 * rowHeight)

  pop()
}

function updateCarbonbySlider(currentCarbon){
  //go through each states
  sliderMarked = []
  for (let i = 1; i < sessions.length; i++) {
    carboni = carbon[i]
    statei = sessions[i].State
    if (carboni > currentCarbon) {
      sliderMarked.push(availableStates[i])
      // worldMap.setFill(availableStates[i], 'purple');
    }
    else{
      // print(availableStates[i])
      // worldMap.setFill(availableStates[i], 'yellow')
    }
  }
  ratio = str(sliderMarked.length/sessions.length*100).substring(0,5)
}



function draw() {
  // Your sketch can go here, but keep in mind that the map will always be on top.
  // showClickedStates(clickedStates)
  // background(255)
  if (!loaded) {
    background(255)
    textAlign(CENTER, CENTER);
    text("Loading " + frameCount, width - 100, height - 10)
  }
  else {
    background(255)
    text("DONE", width - 100, height - 10)

//     ("Check by States");
// "Check Nation-wide");
    if (mySelect.value() == "Check by States"){

    }
    else if (mySelect.value() == "Check Nation-wide"){

      text(minCarbon, width / 2 - 200, height - 30)
      text(maxCarbon, width / 2 + 100, height - 30)
      push()
      fill(0)
      let amount = 0
      amount = mySlider.value()
      updateCarbonbySlider(mySlider.value())
      // ratio = 100
      text("If we restricted the carbon emission to " + amount + " kgCO2e...", 25, 25)
      text(ratio + "% of the states would not pass.", 300, 50)
      text("Hello", width / 2, height / 2)
      pop()
    }


    tableStats(clickedStateShape.id)
    
    //if the value changes, update the plot 
    if (carbonSlideVal != mySlider.value()){
        carbonSlideVal = mySlider.value()
        updateCarbonbySlider(carbonSlideVal)
    }
  

    if (infoPopupState) {
      infoPopup()
    }
  }

}


function mousePressed() {
  if (infoPopupState) {
    infoPopupState = false
  }
}