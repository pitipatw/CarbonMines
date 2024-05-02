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

let carbonSlideVal = 0;

let higherState = [];
let lowerState = [];

let higherCarbon = [];
let lowerCarbon = [];

// let col = color(255,255,255) ; 
let statesColor = []; //should be a dictionary of the state names




// map value to color gradients in the range of 0 to 1. 
function myColor(value) {
  if (value <= 0) { //less than the selected state -> blue tone
    let to = color(255, 0, 0)
  }
  else {
    let to = color(218, 165, 32)
  }
  baseColor = color(255, 255, 255)
  col = lerbColor(baseColor, to, abs(value))
  return col
}

function setup() {
  createCanvas(800, 480);
  background(200);

  let defaultColor = "grey"; 
  let clickedColor = color(255,255,255) //when you select it, it turns white.
  let hoverColor = color(200,200,200) //When you hover it, a darker shade of white (grey?)

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


//Set up the controls buttons on the screen.
function setupControls() {
  mySelect = createSelect();
  mySelect.position(width - 285, height - 50);
  mySelect.option("Check Nation-wide");
  mySelect.option("Check by States");
  mySelect.style('border-radius', '3px');
  mySelect.style('width', '150px');
  mySelect.style('padding', '0.5em');

  mySlider = createSlider(0, 700);
  mySlider.position(width / 2 - 200, height - 30);
  mySlider.size(300);

  myResetButton = createButton("RESET");
  myResetButton.position(width - 75, height - 40);
  myResetButton.mousePressed(reset);
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
  let defaultColor = "grey"; 
  let clickedColor = color(255,255,255) //when you select it, it turns white.
  let hoverColor = color(200,200,200) //When you hover it, a darker shade of white (grey?)

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
    //put the available states into the default color.
    worldMap.setFill(sessions[i].State, defaultColor);
  }
  loaded = true
}

function reset() {
  //when hit, turn every state to grey color, and clickedstate to ""
  for (let i = 1; i < sessions.length; i++) {
    state = sessions[i].State
    worldMap.setFill(sessions[i].State, defaultColor);
  }
  //reset all of the arrays and variables.
  clickedStateShape = "";
  clickedState = "";
  higherStates = [];
  lowerStates = [];

  higherStatesCarbon = [];
  lowerStatesCarbon = [];
}

//Define what happen when click on the map.
function mapClick(shape) {
  let defaultColor = "grey"; 
  let clickedColor = color(255,255,255) //when you select it, it turns white.
  let hoverColor = color(200,200,200) //When you hover it, a darker shade of white (grey?)

  //First, make sure that the element that clicked is not ignoorange.
  if (!ignoreShape(shape.id)) {

    //###THESE LINES can be commented, since we will always colors them over anyway, we dont have to put them back to default.
    //prevent error from the first run, that is, you have to reset the old ones to the default color.
    oldClickedStateShape = clickedStateShape

    //reset the color to normal (only 1 state can be clicked at a time)
    if (availableStates.includes(oldClickedStateShape.id)) {
      worldMap.setFill(oldClickedStateShape, defaultColor);
    }
    //Until HERE

    //Now, we change the clicked color into the color that we want.
    if (availableStates.includes(shape.id)) {
      clickedStateShape = shape
      worldMap.setFill(clickedStateShape, clickedColor);
    }

    //compare carbon and highlight
    currentCarbon = carbon[availableStates.indexOf(clickedStateShape.id)]

    //reset values
    higherStates = [];
    lowerStates = [];

    higherStatesCarbon = [];
    lowerStatesCarbon = [];

    //loop one by one, if larger, push it to the right array with carbon.
    for (let i = 0; i < sessions.length; i++) {
      statei = sessions.State[i]
      if (statei != clickedStateShape.id) {

        carboni = carbon[i]
        statei = sessions[i].State
        statesColor = [] ; 

        if (carboni >= currentCarbon) {
          higherStates.push(availableStates[i])
          higherStatesCarbon.push(carboni)
          // worldMap.setFill(availableStates[i], 'red');
          let val = (carboni - currentCarbon) / (maxCarbon - currentCarbon)
          col = myColor(val)
          worldMap.setFill(availableStates[i], col);
          
        }
        else {
          lowerStates.push(availableStates[i])
          lowerStatesCarbon.push(carboni)
          // worldMap.setFill(availableStates[i], 'red');
          let val = (carboni - currentCarbon) / (currentCarbon - minCarbon)
          col = myColor(val)
          worldMap.setFill(availableStates[i], col);
          
        }
        statesColor.push(col); 
      }

    }
    // allStates = worldMap.listShapes()
  }
  //also update the table.
  print(`click ${shape.id}`);
}

function mapOver(shape) {
  let defaultColor = "grey"; 
  let clickedColor = color(255,255,255) //when you select it, it turns white.
  let hoverColor = color(200,200,200) //When you hover it, a darker shade of white (grey?)

  //Make sure that it's not ignoorange.
  if (!ignoreShape(shape.id)) {
    //if it's the clickable state, put it in white?
    if (availableStates.includes(shape.id)) {
      worldMap.setFill(shape, hoverColor)
    }
    //if it's the currently clicked, put it in darker orange.
    // if (clickedStateShape.id == shape.id) {
    //   //dark read
    //   worldMap.setFill(shape, '#8B0000')
    // }
    print(`over ${shape.id}`);
  }
}

function mapOut(shape) {
  let defaultColor = "grey"; 
  let clickedColor = color(255,255,255) //when you select it, it turns white.
  let hoverColor = color(200,200,200) //When you hover it, a darker shade of white (grey?)

  //Make sure that it's not ignoorange.
  if (!ignoreShape(shape.id)) {
    //If it's the clicked state, put it in it's clicked color, which is white.
    if (shape.id == clickedState) {
      worldMap.setFill(shape, clickedColor);
    }
    else {
      //now, the others has to turn back to the previous color.
      if (availableStates.includes(shape.id)) {
        worldMap.setFill(shape, statesColor[availableStates.indexOf(shape.id)])
      }
    }
    //It it's the marked state, put it in red
    // if (marked.includes(shape.id)) {
    //   worldMap.setFill(shape, 'red');
    // }
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
  let ranki = "No data"; //query the rank
  let carboni = "No data"; //query the carbon

  if (availableStates.includes(name)) {
    ranki = higherStatesCarbon.length
    carboni = str(carbon[availableStates.indexOf(name)])
  }

  rect(boxStartX, boxStartY, boxWidth, boxHeight)
  line(boxStartX, boxStartY + rowHeight, boxStartX + rowWidth, boxStartY + rowHeight)
  fill(0)
  text("State:", boxStartX + 10, boxStartY + 0.75 * rowHeight)
  text(name, boxStartX + 50, boxStartY + 0.75 * rowHeight)

  text("Rank: " + ranki, boxStartX + 10, boxStartY + 0.75 * 3 * rowHeight)
  text("Carbon: " + carboni.substring(0, 5), boxStartX + 10, boxStartY + 0.75 * 4 * rowHeight)

  pop()
}

function updateCarbonbySlider(currentCarbon) {
  //go through each states
  sliderMarked = []
  for (let i = 1; i < sessions.length; i++) {
    carboni = carbon[i]
    statei = sessions[i].State
    if (carboni > currentCarbon) {
      sliderMarked.push(availableStates[i])
      // worldMap.setFill(availableStates[i], 'purple');
    }
    else {
      // print(availableStates[i])
      // worldMap.setFill(availableStates[i], 'yellow')
    }
  }
  ratio = str(sliderMarked.length / sessions.length * 100).substring(0, 5)
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
    if (mySelect.value() == "Check by States") {

    }
    else if (mySelect.value() == "Check Nation-wide") {

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
    if (carbonSlideVal != mySlider.value()) {
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