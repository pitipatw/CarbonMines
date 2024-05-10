//SVG related variables
let worldMap;

//Data related variables
let sessions = [];
let availableStates = [];
let loaded = false;
let eq = {}
let BG = []

let graphX = 75
let graphY = 420
let graphWidth = 100
let graphHeight = 200
//Popup screen state
let infoPopupState = true;

//Click-related variables
let clickedStateShape = "";
let currentColor = [];

//Carbon related variables
let concreteVolume = 0.18 // m3 concrete per m2 building
let carbon = [];
let sortedCarbon = [];
let sortedStates = [];
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
let hoverState = '';

function setup() {
  // let myCanvas = createCanvas(windowWidth, windowHeight);
  let myCanvas = createCanvas(800, 480)
  // myCanvas.parent('canvasContainer'); // This places the canvas in a specific HTML element
  // myCanvas.id('myCanvas'); // Assigns an ID to the canvas
  background(200);
  textFont("Garamond")

  // If you change the dimensions, the aspect ratio will stay the same.
  // The browser will size the map to use as much of the width/height as possible.
  let mapWidth = width * 0.6;  // use 80% of the sketch size
  let mapHeight = height * 0.6;
  // Center the map on the screen. The mapX and mapY
  // coordinates are relative to the sketch location.
  let mapX = (width - mapWidth) / 2 + 75;
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

  drawIntro()
}



//Set up the controls buttons on the screen.
function setupControls() {

  mySlider = createSlider(40, 120);
  mySlider.position(width / 2 - 220, 60);
  mySlider.size(400);
  mySlider.value(80)
  // mySlider.style('background', 'linear-gradient(to right, #e74c3c, #f39c12, #27ae60)'); // Set a gradient background
  mySlider.style('background', "#d3d3d3"); // Set a gradient background
  mySlider.style('border-radius', '5px'); // Set border radius
  mySlider.style('outline', 'none'); // Remove outline
  mySlider.style('-webkit-appearance', 'none'); // Remove default WebKit appearance
  mySlider.style('cursor', 'pointer'); // Change cursor style
  // mySlider.value(0)

  mySelect = createSelect()
  mySelect.position(405, 395)
  mySelect.style('padding', '1px'); // Apply custom styles to the select dropdown
  mySelect.style('background-color', '#f9f9f9'); // Light grey background
  mySelect.style('color', '#333');
  mySelect.style('border', '1px solid #ccc');
  mySelect.style('border-radius', '5px');
  mySelect.style('cursor', 'pointer');
  for (let i = 0; i < otherKeys.length; i++) {
    mySelect.option(otherKeys[i])
  }

  myResetButton = createButton("RESET");
  myResetButton.position(width - 100, height - 40);
  myResetButton.mousePressed(reset);
  myResetButton.style('padding', '10px 20px'); // Apply custom styles to the button
  myResetButton.style('background-color', 'black'); // Blue background
  myResetButton.style('color', 'white'); // White text
  myResetButton.style('border', 'none');
  myResetButton.style('border-radius', '5px');
  myResetButton.style('cursor', 'pointer');
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
  maxCarbon = mean(carbon) + 2 * standardDev

  // Create an array of objects containing carbon values and state names
  let carbonStatePairs = [];
  for (let i = 0; i < carbon.length; i++) {
    carbonStatePairs.push({ carbonValue: carbon[i], stateName: availableStates[i] });
  }

  // Sort the array of objects based on carbon values
  carbonStatePairs.sort((a, b) => a.carbonValue - b.carbonValue);

  // Extract sorted carbon values and state names
  for (let pair of carbonStatePairs) {
    sortedCarbon.push(pair.carbonValue);
    sortedStates.push(pair.stateName);
  }


  // Display the sorted carbon values and state names
  console.log("Sorted Carbon Values:", sortedCarbon);
  console.log("Sorted State Names:", sortedStates);

  loaded = true

}

function reset() {
  push()
  //when hit, turn every state to grey color, and clickedstate to ""
  statesColor = []
  for (let i = 1; i < sessions.length; i++) {
    state = sessions[i].State
    worldMap.setFill(sessions[i].State, defaultColor);
    statesColor.push(defaultColor)
  }
  //reset all of the arrays and variables.
  mySlider.value(0)
  clickedStateShape = "nothing";
  higherStates = [];
  lowerStates = [];

  higherStatesCarbon = [];
  lowerStatesCarbon = [];
  pop()
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
      dictCarbonState.push({ "State": statei, "Carbon": carboni })
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

function tableStats(name, boxStartX, boxStartY, singleMode) {
  push();
  let boxWidth = 180;
  let boxHeight = 200;
  let rowHeight = 20;
  let textColor = singleMode ? 0 : 200;
  let backgroundColor = singleMode ? "#fafafa" : "#fafafa";

  // Draw background box
  fill(backgroundColor);
  push()
  stroke(0);
  strokeWeight(2);
  rect(boxStartX, boxStartY, boxWidth, boxHeight);
  fill("#fafafa")
  rect(boxStartX, boxStartY + boxHeight, boxWidth, 125)
  pop()

  
  // State Name (Static Text - Bold)
  fill(textColor);
  textStyle(BOLD);
  textSize(14);
  textAlign(LEFT, TOP);
  text("State:", boxStartX + 10, boxStartY + 10);

  push()
  fill(0)
  textSize(12)
  text("Carbon distribution", boxStartX + 10, 310)
  pop()

  // State Abbreviation (Dynamic Text)
  textStyle(NORMAL); // Reset text style to normal for dynamic text
  let stateAbbreviation = stateAbbreviations[name] || "No data";
  text(stateAbbreviation, boxStartX + 60, boxStartY + 10);

  // Rank (Static Text - Bold)
  textStyle(BOLD);
  text("Rank:", boxStartX + 10, boxStartY + 40);

  // Rank Value (Dynamic Text)
  textStyle(NORMAL);
  let ranki = "No data";
  if (availableStates.includes(name)) {
    ranki = (higherStatesCarbon.length + 1).toString();
  }
  text(ranki, boxStartX + 60, boxStartY + 40);

  // Carbon (Static Text - Bold)
  textStyle(BOLD);
  text("Carbon:", boxStartX + 10, boxStartY + 70);

  // Carbon Value (Dynamic Text)
  textStyle(NORMAL);
  let carboni = "No data";
  if (availableStates.includes(name)) {
    carboni = carbon[availableStates.indexOf(name)].toFixed(2) + " kgCO2e/m2";
  }
  text(carboni, boxStartX + 60, boxStartY + 70);

  // Header for closest states (Static Text - Bold)
  textStyle(BOLD);
  text("4 closest states:", boxStartX + 10, boxStartY + 5 * rowHeight);

  // Find and display closest states
  // print("Before find closest")
  let closestStates = findClosestStates(carbon[availableStates.indexOf(name)]);
  let yOffset = boxStartY + 6 * rowHeight;
  for (let i = 0; i < closestStates.length; i++) {
    let state = closestStates[i];
    // print(state)
    textStyle(NORMAL);
    text(stateAbbreviations[state.State], boxStartX + 20, yOffset + i * rowHeight);
    // Display additional data if needed (e.g., carbon values)
    // text(state.carbon, boxStartX + 150, yOffset + i * rowHeight);
  }

  pop();
}


// function tableStats(name, boxStartX, boxStartY, singleMode) {
//   push();
//   let boxWidth = 180;
//   let boxHeight = 200;
//   let rowHeight = 20;
//   let textColor = singleMode ? 0:100;
//   let backgroundColor = singleMode ? 255:240; 

//   // Draw background box
//   fill(backgroundColor);
//   stroke(200);
//   strokeWeight(1);
//   rect(boxStartX, boxStartY, boxWidth, boxHeight);

//   // State Name
//   fill(textColor);
//   textStyle(BOLD);
//   textSize(14);
//   textAlign(LEFT, TOP);
//   text("State: " + stateAbbreviations[name], boxStartX + 10, boxStartY + 10);

//    // Rank
//   let ranki = "No data";
//   if (availableStates.includes(name)) {
//     ranki = higherStatesCarbon.length + 1;
//   }
//   text("Rank: " + ranki, boxStartX + 10, boxStartY + 40);

//   // Carbon
//   let carboni = "No data";
//   if (availableStates.includes(name)) {
//     carboni = carbon[availableStates.indexOf(name)].toFixed(2) + " kgCO2e/m2";
//   }
//   text("Carbon: " + carboni, boxStartX + 10, boxStartY + 70);
//   text("4 closest states:", boxStartX +10 , boxStartY + 5*rowHeight)
//   // print(name)
//   let closestStates = findClosestStates(name, carboni);
//   // print(closestStates)
//   let yOffset = boxStartY + 6 * rowHeight;
//   for (let i = 0; i < closestStates.length; i++) {
//     let state = closestStates[i];
//     // print(state)
//     print(boxStartX + 10)
//     text(stateAbbreviations[state.State], boxStartX + 20, yOffset + i * rowHeight);
//         // text(state.carbon, boxStartX + 250, yOffset + i * rowHeight);
//   }
//   pop();
// }

//   let rowWidth = boxWidth;
//   let ranki = "No data"; //query the rank
//   let carboni = "No data"; //query the carbon

//   if (availableStates.includes(name)) {
//     ranki = higherStatesCarbon.length + 1
//     carboni = str(carbon[availableStates.indexOf(name)])
//   }
//   // find 4 other states that have close co2 
//   //c1 c2 c3 c4 
//   dictCarbonState.sort((a, b) => a.Carbon - b.Carbon);
//   // print(dictCarbonState)
//   // get the first 4 and display them 

//   //get the first 4, then workfrom there.
//   rect(boxStartX, boxStartY, boxWidth, boxHeight)
//   line(boxStartX, boxStartY + rowHeight, boxStartX + rowWidth, boxStartY + rowHeight)
//   if (singleMode){
//     fill(0)
//   }
//   else {
//     fill(210)
//   }
//   push()
//   textStyle(BOLD)
//   text("State: " + stateAbbreviations[name], boxStartX + 2.5, boxStartY + 0.75 * rowHeight)
//   pop()
//   // text(stateAbbreviations[name], boxStartX + 50, boxStartY + 0.75 * rowHeight)

//   text("Rank: " + ranki, boxStartX + 10, boxStartY + 0.6 * 3 * rowHeight)
//   if (carboni == "No data") {
//     text("Carbon: " + carboni, boxStartX + 10, boxStartY + 0.6 * 4 * rowHeight)
//   }
//   else {
//     text("Carbon: " + carboni.substring(0, 5) + " units", boxStartX + 10, boxStartY + 0.6 * 4 * rowHeight)
//   }
//   if (dictCarbonState.length > 1) {
//     push()
//     textStyle(BOLD)
//     text("Top 4 closest states", boxStartX + 2.5, boxStartY + 0.6 * 4 * rowHeight + 17.5)
//     line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 5, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 5)
//     line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 20, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 20)
//     pop()
//     let endPoint = 0
//     if (ranki != "No data") {
//       for (let i = 0; i <= 4; i++) {
//         let fix = 0
//         if (dictCarbonState[i].state == stateAbbreviations[name]) {
//           i += 1
//           fix = 1
//         }
//         // print(dictCarbonState[i].State)
//         text(stateAbbreviations[dictCarbonState[i].State], boxStartX + 10, boxStartY + 80 + (i - fix) * 10)
//         endPoint = boxStartY + 80 + (i - fix) * 10
//       }

//       push()
//       textStyle(BOLD)
//       endPoint = endPoint + 5
//       text("Carbon equivalent", boxStartX + 2.5, endPoint + 17.5)
//       line(boxStartX, endPoint + 5, boxStartX + rowWidth, endPoint + 5)
//       line(boxStartX, endPoint + 20, boxStartX + rowWidth, endPoint + 20)
//       pop()
//       let selectedFood = mySelect.value()
//       let numberOfFood = round(18 * carboni / eq[selectedFood])
//       // text(selectedFood, boxStartX + 10, endPoint + 35)
//       text('The embodied carbon of an average US house in this state (18 sq.m) would be equivalent to ' + selectedFood + " " + str(numberOfFood).substring(0, 5) + " times.", boxStartX + 5, endPoint + 25, boxWidth - 2.5, boxHeight)

//     }
//     else { //empty table.
//       push()
//       textStyle(BOLD)
//       text("Top 4 closest states", boxStartX + 2.5, boxStartY + 0.6 * 4 * rowHeight + 17.5)
//       line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 5, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 5)
//       line(boxStartX, boxStartY + 0.6 * 4 * rowHeight + 20, boxStartX + rowWidth, boxStartY + 0.6 * 4 * rowHeight + 20)
//       endPoint = boxStartY + 80 + 4 * 10 + 5
//       text("Carbon equivalent", boxStartX + 2.5, endPoint + 17.5)
//       line(boxStartX, endPoint + 5, boxStartX + rowWidth, endPoint + 5)
//       line(boxStartX, endPoint + 20, boxStartX + rowWidth, endPoint + 20)
//       pop()
//     }
//   }
//   pop()
// }


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
    push()
    textSize(10)
    text("DONE", width, height - 10)
    pop()

    // push();
    // fill(255,127)
    // rect(40,10, 750,75 )
    // pop();

    if (currentSlideValue != mySlider.value()) {
      singleMode = false
      print("entering Slider Mode")
    }

    push()
    // fill(0)
    textSize(15)
    textStyle(BOLD)
    text("Please select an activity: ", 250, 410)
    pop()

    push()
    if (singleMode) { //clickMode
      // text("Single State Mode", 10, 10)
      tableStats(clickedStateShape.id, 40, 100, singleMode)
      getGraph(clickedStateShape, graphX, graphY, graphWidth)
    }
    else { //sliderMode
      currentSlideValue = mySlider.value()
      tableStats("NA", 40, 100, singleMode)

      //if the value changes, update the plot 
      if (carbonSlideVal != mySlider.value()) {
        carbonSlideVal = mySlider.value()
        updateCarbonbySlider(carbonSlideVal)
      }
      // updateCarbonbySlider(mySlider.value())
      getGraphMulti(mySlider.value(), graphX, graphY, graphWidth)
    }
    textSize(20)
    let amount = 0
    amount = mySlider.value()
    if (ratio == 0) {
      ratioText = "all of the states would pass."
    }
    else if (ratio == 100) {
      ratioText = "none of the states would pass."
    }
    else {
      ratioText = ratio.substring(0, 4) + "% of the states would not pass."
    }
    push()
    textStyle(BOLD)
    textSize(18)
    text("If we restricted the carbon emission to " + str(amount).substring(0, 5) + " kgCO2e/sq.m, " + ratioText, 55, 40)
    pop()
    pop()

    botTable(320, 420)
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
  // clickedState = state
}


function getGraph(name, graphX, graphY, graphWidth) {
  push()
  noStroke(); // Ensure no outline for rectangles
  fill(0) //black 
  for (let i = 0; i < availableStates.length; i++) {
    carboni = sortedCarbon[i]
    state = sortedStates[i]
    if (name.id == sortedStates[i]) {
      fill(255);
      // fill(color(17, 101, 48))
    }
    else {
      fill(0)
      fill(color(255, 0, 0)) //red
      // print(statesColor[availableStates.indexOf(name.id)])
      if (statesColor.length > 1 ){
        fill(statesColor[availableStates.indexOf(state)])
      }

    }
    // Calculate rectangle coordinates and dimensions
    let rectX = i * (graphWidth / sortedCarbon.length) + graphX;
    let rectY = graphY - carboni; // Invert Y-axis for correct orientation
    let rectWidth = graphWidth / sortedCarbon.length + 1;
    let rectHeight = carboni;
    rect(rectX, rectY, rectWidth, rectHeight);

    // Check if mouse is over the bar
    if (rectX + 0.5 < mouseX && mouseX < rectX + rectWidth - 0.5 && mouseY > rectY - rectHeight) {
      push()
      hoverState = state; // Set hover state
      fill(0);
      textSize(12);
      textAlign(CENTER, TOP);
      if (graphY - rectHeight - 20 < 300) {
        text(state, rectX + 20, graphY - rectHeight);
      }
      else {
        // text(state, rectX-10, graphY - rectHeight-20);
        text(state, rectX - 10, graphY - rectHeight - 20);
      }
   
      // Draw the rectangle representing carbon value
      rect(rectX, rectY, rectWidth, rectHeight);
      pop();
    }
    
  }
  pop()
}
function getGraphMulti(value, graphX, graphY, graphWidth) {

  push();
  noStroke(); // Ensure no outline for rectangles
  for (let i = 0; i < sortedCarbon.length; i++) {
    let carboni = sortedCarbon[i];
    let state = sortedStates[i];

    // Fill the bar with the determined color
    // if (carboni < value) {
    //   fill(255);
    //   // fill(color(17, 101, 48))
    // }
    // else {
    //   fill(0); // Black for values above or equal to the threshold
    //   fill(color(255, 0, 0))
      fill(statesColor[availableStates.indexOf(state)])

    // }

    // Calculate rectangle coordinates and dimensions
    let rectX = i * (graphWidth / sortedCarbon.length) + graphX;
    let rectY = graphY - carboni; // Invert Y-axis for correct orientation
    let rectWidth = graphWidth / sortedCarbon.length + 1;
    let rectHeight = carboni;

    // Check if mouse is over the bar
    if (rectX + 0.5 < mouseX && mouseX < rectX + rectWidth - 0.5 && mouseY > rectY - rectHeight) {
      fill(200, 100, 100); // Highlight color when hovered
      hoverState = state; // Set hover state
      fill(0);
      textSize(12);
      textAlign(CENTER, TOP);
      if (graphY - rectHeight - 20 < 300) {
        text(state, rectX + 20, graphY - rectHeight);
      }
      else {
        // text(state, rectX-10, graphY - rectHeight-20);
        text(state, rectX - 10, graphY - rectHeight - 20);
      }
    }
    // else {
    //   fill(100, 200, 100); // Normal color
    // }

    // Draw the rectangle representing carbon value
    rect(rectX, rectY, rectWidth, rectHeight);
  }
  pop();


}


function botTable(x, y) {
  let tableWidth = 300
  let tableHeight = 55
  let padding = 2.5
  push();
  fill(255);
  // noStroke()
  
  tint(255, 101)
  strokeWeight(2);
  rect(x-padding, y-padding, tableWidth+2*padding, tableHeight+2*padding)
  pop();


  let selectedActivity = mySelect.value()
  let numberOfActivity = round(180 * carboni / eq[selectedActivity])
  // text(selectedFood, boxStartX + 10, endPoint + 35)
  push()
  textSize(15)
  text('The embodied carbon of an average US house in '+ stateAbbreviations[clickedStateShape.id] + ' (180 sq.m) would be equivalent to ' + selectedActivity + " " + str(numberOfActivity).substring(0, 5) + " times.", x, y, tableWidth - 2.5, tableHeight)
  pop()
}
// function getGraphMulti(value) { 
//   // print("In graph multi")
//   let graphX = 50
//   let graphY = 350
//   let graphWidth = 100
//   push()
//   fill(0)
//   for (let i = 0; i < availableStates.length ; i++) {
//     carboni= sortedCarbon[i]
//     if (carboni < value) { 
//       fill(200)
//     }
//     else{
//       fill(0)
//     }
//     //draw graph
//     rect(i * graphWidth/carbon.length + graphX, graphY - carboni, graphWidth/carbon.length, carboni)
//   }
//    //determine highest value
//   //  maxValue=max(budgetValues);
//   // for (var k=0;k<maxValue;k=k+50){
//   //   text(k,10,420-k);
//   // }
//   pop()
// }

// function showIntro(){
//   infoPopupState = true
//   print("Clicked Info")
//   let rect1 = select('#myRectangle1');
//   rect1.style('display', 'block');

//   let rect2 = select('#myRectangle2');
//   rect2.style('display', 'block');
// }

// move the sliders to the top or near the text, 
// keep the bars 
// compare with other countries

// move the equivalent goes to the bottom. Long paragraph 
// Sort the bars, turn off the stroke
function windowResized() {
  // Resize the canvas to match the new window dimensions
  resizeCanvas(windowWidth, windowHeight);
}
function mouseMoved() {
  // Reset hover state when mouse moves out of bars area
  hoverState = '';
}