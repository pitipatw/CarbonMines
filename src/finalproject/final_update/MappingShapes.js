//SVG related variables
let worldMap;

//Data related variables
let sessions = [];
let availableStates = [];
let loaded = false;
let eq = {}
let BG = []

//Popup screen state
let infoPopupState = true;

//Click-related variables
let clickedStateShape = "";
let currentColor = [];

//Carbon related variables
let concreteVolume = 0.18 // m3 concrete per m2 building
let carbon = [];
let carboni;
let minCarbon = 10000;
let maxCarbon = 0;
let higherStates = [];
let lowerStates = [];
let val; //relative carbon value
let higherStatesCarbon = [];
let lowerStatesCarbon = [];
let dictCarbonState = [];
let otherKeys = []
//Mode 
let singleMode = true;

//Slider related variables
let mySlider;
let currentSlideValue = 0;
let carbonSlideVal = 0;

//Color setup
let statesColor = []; //should be a dictionary of the state names
let defaultColor = "grey";
// let clickedColor = "color(255,255,255)" //when you select it, it turns white.
// let hoverColor = "color(200,200,200)" //When you hover it, a darker shade of white (grey?)
let clickedColor = "white" //when you select it, it turns white.
let hoverColor = "white" //When you hover it, a darker shade of white (grey?)
let outColor = "white"
//Text related variables
let ratioText = "";
let textInTheBox = "The built environment contributes substantial carbon emissions through concrete construction, which accounts for 11% of total greenhouse gas emission.<br><br>Policy makers try to mitigate the problem by limiting the amount of embodied carbon per building. This project aims to raise awareness that limiting carbon by number does not reflect how locals use their material and it might be unfair to do so. Hence, alternative, more data/region specific is needed to address the problem."
// text("<<<Click anywhere to continue>>>", width - 220, 75)"

// map value to color gradients in the range of 0 to 1. 
function myColor(value) {
  let to
  if (value >= 0) {
    to = color(255, 0, 0)
  }
  else {
    // to = color(4, 118, 208)
    to = color(17, 101, 48)
  }
  baseColor = color(255, 255, 255)
  col = lerpColor(baseColor, to, abs(value))
  // print(col)
  return col
}



function setup() {
  let myCanvas = createCanvas(800, 480);
  // myCanvas.parent('canvasContainer'); // This places the canvas in a specific HTML element
  // myCanvas.id('myCanvas'); // Assigns an ID to the canvas
  background(200);

  // If you change the dimensions, the aspect ratio will stay the same.
  // The browser will size the map to use as much of the width/height as possible.
  let mapWidth = width * 0.75;  // use 80% of the sketch size
  let mapHeight = height * 0.75;
  // Center the map on the screen. The mapX and mapY
  // coordinates are relative to the sketch location.
  let mapX =(width - mapWidth);
  let mapY = (height - mapHeight) / 2;

  // let mapPath = "data/world-robinson.svg";
  //let mapPath = "data/world-equirectangular.svg";
  //let mapPath = "data/us-counties.svg";
  let mapPath = "data/us-states.svg";
  let stateCarbonPath = "data/statecarbon.json"


  // This will create a new SVG map from the 'robinson.svg' file in the data folder.
  // Once the map has finished loading, the mapReady() function will be called.
  worldMap = new SimpleSVG(mapPath, mapX, mapY, mapWidth, mapHeight, mapReady);
  // worldMap.id("worldMapId")
  //load the dataset
  stateCarbon = loadJSON(stateCarbonPath, dataLoaded)
  BG = loadImage('background.jpeg')

  print(eq.burger)
  otherKeys = Object.keys(eq)
  // infoPopup()
  // for (let i = 0 ; i<)
  // mySelect.option('red');
  // mySelect.option('green');
  // mySelect.option('blue');
  // mySelect.option('yellow');
  print(otherKeys)

  let myRectangle = createDiv(textInTheBox);
  myRectangle.id('myRectangle1');
  myRectangle.position(width / 5, height / 5);
  // Style the rectangle using CSS properties
  myRectangle.style('width', width - 2 * width / 5); // Width of the rectangle
  myRectangle.style('height', height - 2 * height / 5); // Height of the rectangle
  myRectangle.style('padding', "10px")
  myRectangle.style('font-size', "18px")
  myRectangle.style('background-color', '#D4D4D4'); // Color of the rectangle
  myRectangle.style('border', '2px solid black'); // Optional border
  myRectangle.style("z-index", "9999")


  let myOver = createDiv('');
  myOver.id('myRectangle2');
  myOver.position(0, 0);
  // Style the rectangle using CSS properties
  myOver.style('width', width); // Width of the rectangle
  myOver.style('height', height); // Height of the rectangle
  myOver.style('padding', "10px")
  myOver.style('font-size', "18px")
  myOver.style('background-color', 'green'); // Color of the rectangle
  myOver.style('border', '2px solid black'); // Optional border
  myOver.style("z-index", "9998")
  myOver.style("opacity", 0.5);



}

//Set up the controls buttons on the screen.
function setupControls() {

  mySlider = createSlider(40, 120);
  mySlider.position(width / 2 - 200, height - 30);
  mySlider.size(300);
  mySlider.value(400)

  mySelect = createSelect()
  mySelect.position(40, 380)
  for (let i = 0; i < otherKeys.length; i++) {
    mySelect.option(otherKeys[i])
  }

  myResetButton = createButton("RESET");
  myResetButton.position(width - 175, height - 32);
  myResetButton.mousePressed(reset);

  // myShowIntroButton = createButton("INTRO")
  // myShowIntroButton.position(width - 100, height - 32);
  // myShowIntroButton.mousePressed(showIntro);
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

}

function preload() {
  eq = loadJSON("data/othercarbon.json")
}

//Load the data from the json file.
function dataLoaded(data) {

  sessions = data;
  for (let i = 0; i < sessions.length; i++) {
    availableStates.push(sessions[i].State)
    thisCarbon = concreteVolume * sessions[i].Carbon
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
  standardDev = stddev(carbon)
  maxCarbon = mean(carbon) + 2*standardDev
  // minCarbon = mean(carbon) - 2*standardDev
  loaded = true
  setupControls()

  // print(carbon)
}

function reset() {
  //when hit, turn every state to grey color, and clickedstate to ""
  for (let i = 1; i < sessions.length; i++) {
    state = sessions[i].State
    worldMap.setFill(sessions[i].State, defaultColor);
    statesColor.push(defaultColor)
  }
  //reset all of the arrays and variables.
  mySlider.value(0)
  clickedStateShape = "";
  higherStates = [];
  lowerStates = [];

  higherStatesCarbon = [];
  lowerStatesCarbon = [];
}

//Define what happen when click on the map.
function mapClick(shape) {
  singleMode = true;
  //First, make sure that the element that clicked is not ignoorange.
  if (!ignoreShape(shape.id)) {

    //Now, we change the clicked color into the color that we want.
    if (availableStates.includes(shape.id)) {
      clickedStateShape = shape
      worldMap.setFill(clickedStateShape, clickedColor);
    }

    //reset values
    higherStates = [];
    lowerStates = [];

    higherStatesCarbon = [];
    lowerStatesCarbon = [];
    statesColor = [];
    dictCarbonState = []
    //compare carbon and highlight
    clickedCarbon = carbon[availableStates.indexOf(clickedStateShape.id)]

    //loop one by one, if larger, push it to the right array with carbon.
    for (let i = 0; i < sessions.length; i++) {
      statei = sessions[i].State
      if (statei != clickedStateShape.id) {
        carboni = carbon[i]
        // print(carboni, statei, i, carbon.length)
        if (carboni >= clickedCarbon) {
          higherStates.push(availableStates[i])
          higherStatesCarbon.push(carboni)
          // worldMap.setFill(availableStates[i], 'red');
          if (maxCarbon == clickedCarbon) {
            val = 1
          }
          else {
            val = (carboni - clickedCarbon) / (maxCarbon - clickedCarbon)
            // print("Higher",val)
          }
        }
        else {
          lowerStates.push(availableStates[i])
          lowerStatesCarbon.push(carboni)
          if (minCarbon == clickedCarbon) {
            val = -1
          }
          else {
            val = (carboni - clickedCarbon) / (clickedCarbon - minCarbon)
            // print(carboni, clickedCarbon)
            // print("lower",val, carboni, clickedCarbon, minCarbon)
          }
        }
        // print(val)
        col = myColor(val)
        worldMap.setFill(statei, col);
      }
      else {
        print(clickedColor)
        col = clickedColor
        worldMap.setFill(statei, clickedColor);
        // worldMap.setFill(statei, "green");
      }
      dictCarbonState.push({ "State": statei, "Carbon": abs(val) })
      statesColor.push(col)
    }
    // allStates = worldMap.listShapes()
  }
  //also update the table.
  print(dictCarbonState)

  print(`click ${shape.id}`);
  print(higherStates)
  print(lowerStates)
}

function mapOver(shape) {
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
  print(statesColor)
  print("OUT")
  //Make sure that it's not ignoorange.
  print(shape.id)
  print("clickedState", clickedStateShape.id)

  if (!ignoreShape(shape.id)) {
    //If it's the clicked state, put it in it's clicked color, which is white.
    if (shape.id == clickedStateShape.id) {
      print(clickedColor)
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

function updateCarbonbySlider(carbonValue) {
  //go through each states
  //reset values
  higherStates = [];
  lowerStates = [];

  higherStatesCarbon = [];
  lowerStatesCarbon = [];
  statesColor = [];

  //loop one by one, if larger, push it to the right array with carbon.
  for (let i = 0; i < sessions.length; i++) {
    statei = sessions[i].State
    carboni = carbon[i]
    // print(carboni, statei, i, carbon.length)
    if (carboni >= carbonValue) {
      higherStates.push(availableStates[i])
      higherStatesCarbon.push(carboni)
      // worldMap.setFill(availableStates[i], 'red');
      if (maxCarbon == carbonValue) {
        val = 1
      }
      else {
        val = (carboni - carbonValue) / (maxCarbon - carbonValue)
        // print("Higher",val)
      }
    }
    else {
      lowerStates.push(availableStates[i])
      lowerStatesCarbon.push(carboni)
      if (minCarbon == carbonValue) {
        val = -1
      }
      else {
        val = (carboni - carbonValue) / (carbonValue - minCarbon)
        // print(carboni, clickedCarbon)
        // print("lower",val, carboni, clickedCarbon, minCarbon)
      }
    }
    // print(val)
    col = myColor(val)
    worldMap.setFill(statei, col);
    statesColor.push(col)
  }
  // allStates = worldMap.listShapes()
  //also update the table.
  // print(`click ${shape.id}`);
  ratio = str(higherStates.length / sessions.length * 100)
}

function compareToOther() {

}


function tableStats(name, boxStartX, boxStartY, singleMode) {

  push()
  fill(255)
  let boxWidth = 120;
  let boxHeight = 260;
  let rowHeight = 20;
  let rowWidth = boxWidth;
  let ranki = "No data"; //query the rank
  let carboni = "No data"; //query the carbon

  if (availableStates.includes(name)) {
    ranki = higherStatesCarbon.length + 1
    carboni = str(carbon[availableStates.indexOf(name)])
  }
  // find 4 other states that have close co2 
  //c1 c2 c3 c4 
  dictCarbonState.sort((a, b) => a.Carbon - b.Carbon);
  // print(dictCarbonState)
  // get the first 4 and display them 

  //get the first 4, then workfrom there.
  rect(boxStartX, boxStartY, boxWidth, boxHeight)
  line(boxStartX, boxStartY + rowHeight, boxStartX + rowWidth, boxStartY + rowHeight)
  if (singleMode){
    fill(0)
  }
  else {
    fill(210)
  }
  push()
  textStyle(BOLD)
  text("State: " + stateAbbreviations[name], boxStartX + 2.5, boxStartY + 0.75 * rowHeight)
  pop()
  // text(stateAbbreviations[name], boxStartX + 50, boxStartY + 0.75 * rowHeight)

  text("Rank: " + ranki, boxStartX + 10, boxStartY + 0.6 * 3 * rowHeight)
  if (carboni == "No data") {
    text("Carbon: " + carboni, boxStartX + 10, boxStartY + 0.6 * 4 * rowHeight)
  }
  else {
    text("Carbon: " + carboni.substring(0, 5) + " unit", boxStartX + 10, boxStartY + 0.6 * 4 * rowHeight)
  }
  if (dictCarbonState.length > 1) {
    push()
    textStyle(BOLD)
    text("Top 4 closest states", boxStartX + 2.5, boxStartY + 0.6 * 4 * rowHeight + 17.5)
    line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 5, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 5)
    line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 20, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 20)
    pop()
    let endPoint = 0
    if (ranki != "No data") {
      for (let i = 0; i <= 4; i++) {
        let fix = 0
        if (dictCarbonState[i].state == stateAbbreviations[name]) {
          i += 1
          fix = 1
        }
        // print(dictCarbonState[i].State)
        text(stateAbbreviations[dictCarbonState[i].State], boxStartX + 10, boxStartY + 80 + (i - fix) * 10)
        endPoint = boxStartY + 80 + (i - fix) * 10
      }

      push()
      textStyle(BOLD)
      endPoint = endPoint + 5
      text("Carbon equivalent", boxStartX + 2.5, endPoint + 17.5)
      line(boxStartX, endPoint + 5, boxStartX + rowWidth, endPoint + 5)
      line(boxStartX, endPoint + 20, boxStartX + rowWidth, endPoint + 20)
      pop()
      let selectedFood = mySelect.value()
      let numberOfFood = round(18 * carboni / eq[selectedFood])
      // text(selectedFood, boxStartX + 10, endPoint + 35)
      text('The embodied carbon of an average US house (18 sq.m) would be equivalent to ' + selectedFood + " " + str(numberOfFood).substring(0, 5) + " times.", boxStartX + 5, endPoint + 25, boxWidth - 2.5, boxHeight)

    }
    else { //empty table.
      push()
      textStyle(BOLD)
      text("Top 4 closest states", boxStartX + 2.5, boxStartY + 0.6 * 4 * rowHeight + 17.5)
      line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 5, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 5)
      line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 20, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 20)
      endPoint = boxStartY + 80 + 4 * 10 + 5
      text("Carbon equivalent", boxStartX + 2.5, endPoint + 17.5)
      line(boxStartX, endPoint + 5, boxStartX + rowWidth, endPoint + 5)
      line(boxStartX, endPoint + 20, boxStartX + rowWidth, endPoint + 20)
      pop()
    }
  }
  pop()
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
    background(240)
    push()
    tint(255, 101)
    image(BG, 0, 0, width, height);
    pop()
    text("DONE", width - 100, height - 10)
    push()
    fill(0)
    text("Min:", width / 2 - 320, height - 30)
    text("Max:", width / 2 + 110, height - 30)
    // text(str(minCarbon).substring(0, 5)+ " kgCO2e/sq.m", width / 2 - 320, height - 15)
    // text(str(maxCarbon).substring(0, 5)+ " kgCO2e/sq.m", width / 2 + 110, height - 15)
    text(str(40).substring(0, 5) + " kgCO2e/sq.m", width / 2 - 320, height - 15)
    text(str(120).substring(0, 5) + " kgCO2e/sq.m", width / 2 + 110, height - 15)
    pop()

    if (currentSlideValue != mySlider.value()) {
      singleMode = false
      print("entering Slider Mode")
    }

    push()
    if (singleMode) { //clickMode
      mySelect.show()
      text("Single State Mode", 10, 10)
      tableStats(clickedStateShape.id, 40, 100, singleMode)
      fill(150)
      push()
      fill(0)
      text("Please select an activity", 40, 375)
      pop()
    }
    else { //sliderMode
      fill(0)
      mySelect.hide()
      currentSlideValue = mySlider.value()
      tableStats("NA", 40, 100, singleMode)

      //if the value changes, update the plot 
      if (carbonSlideVal != mySlider.value()) {
        carbonSlideVal = mySlider.value()
        updateCarbonbySlider(carbonSlideVal)
      }
      updateCarbonbySlider(mySlider.value())

    }
    textSize(20)
    let amount = 0
    amount = mySlider.value()
    if (ratio == 0) {
      ratioText = "All of the states would pass."
    }
    else if (ratio == 100) {
      ratioText = "None of the states would pass."
    }
    else {
      ratioText = ratio.substring(0, 4) + "% of the states would not pass."
    }
    // str(minCarbon).substring(0, 5)
    push()
    textStyle(BOLD)
    text("If we restricted the carbon emission to " + str(amount).substring(0, 5) + " kgCO2e/sq.m,", 50, 40)
    text(ratioText, 350, 65)
    pop()
    pop()
  }

}

function mousePressed() {
  if (infoPopupState) {
    infoPopupState = false
    let rect1 = select('#myRectangle1');
    rect1.style('display', 'none'); // This hides the element

    let rect2 = select('#myRectangle2');
    rect2.style('display', 'none'); // This hides the element
  }
}

// function showIntro(){
//   infoPopupState = true
//   print("Clicked Info")
//   let rect1 = select('#myRectangle1');
//   rect1.style('display', 'block');

//   let rect2 = select('#myRectangle2');
//   rect2.style('display', 'block');
// }