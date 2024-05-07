//SVG related variables
let worldMap;

//Data related variables
let sessions = []; 
let availableStates = [];
let loaded = false ;

//Popup screen state
let infoPopupState = true;

//Click-related variables
let clickedStateShape = "";
let currentColor = [];

//Carbon related variables
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

// map value to color gradients in the range of 0 to 1. 
function myColor(value) {
  let to
  if (value >= 0) { //less than the selected state -> blue tone
    to = color(255, 0, 0)
  }
  else {
    to = color(4, 118, 208)
  }
  baseColor = color(255, 255, 255)
  col = lerpColor(baseColor, to, abs(value))
  return col
}



function setup() {
  createCanvas(800, 480);
  background(200);

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
  // infoPopup()

}


//Set up the controls buttons on the screen.
function setupControls() {

  mySlider = createSlider(0, 700);
  mySlider.position(width / 2 - 200, height - 30);
  mySlider.size(300);
  mySlider.value(400)

  myResetButton = createButton("RESET");
  myResetButton.position(width -175, height - 32);
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
  
}


//Load the data from the json file.
function dataLoaded(data) {

  sessions = data;
  for (let i = 0; i < sessions.length; i++) {
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
      else{
        print(clickedColor)
        col = clickedColor
        worldMap.setFill(statei, clickedColor);
        // worldMap.setFill(statei, "green");
      }
    dictCarbonState.push({"State": statei, "Carbon": abs(val)})
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
  print("clickedState",clickedStateShape.id)

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

function tableStats(name,boxStartX, boxStartY) {

  push()
  let boxWidth = 120;
  let boxHeight = 130;
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
  dictCarbonState.sort((a,b) => a.Carbon - b.carbon) ; 
  // print(dictCarbonState)
  // get the first 4 and display them 

  //get the first 4, then workfrom there.
  rect(boxStartX, boxStartY, boxWidth, boxHeight)
  line(boxStartX, boxStartY + rowHeight, boxStartX + rowWidth, boxStartY + rowHeight)
  fill(0)
  text("State: "+stateAbbreviations[name], boxStartX + 10, boxStartY + 0.75 * rowHeight)
  // text(stateAbbreviations[name], boxStartX + 50, boxStartY + 0.75 * rowHeight)

  text("Rank: " + ranki, boxStartX + 10, boxStartY + 0.75 * 3 * rowHeight)
  text("Carbon: " + carboni.substring(0, 5), boxStartX + 10, boxStartY + 0.75 * 4 * rowHeight)
  for (let i = 0 ;i<= 4; i++){ 
    print(i)
    print(dictCarbonState[i].State)
    // text(dictCarbonState[i].State , boxStartX, boxStartY + i*10)
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
    text("DONE", width - 100, height - 10)
    push()
    fill(0)
    text("Min:", width/2 - 250, height - 30)
    text("Max:", width/2 + 150,height - 30)
    text(str(minCarbon).substring(0, 5)+ " kgCO2e", width / 2 - 250, height - 20)
    text(str(maxCarbon).substring(0, 5)+ " kgCO2e", width / 2 + 150, height - 20)
    pop()
    if (currentSlideValue != mySlider.value()) {
      singleMode = false
      print("entering Slider Mode")
    }
    
    if (singleMode){
      text("Single State Mode", 10,10)
      tableStats(clickedStateShape.id ,20,300)
    }
    else{
      push()
      fill(0)
      let amount = 0
      amount = mySlider.value()
      updateCarbonbySlider(mySlider.value())
      text("If we restricted the carbon emission to " + amount + " kgCO2e...", 225, 25)
      if (ratio == 0){
        ratioText = "All of the states would pass."
      }
      else if (ratio == 100){
        ratioText = "None of the states would pass."
      }
      else {
        ratioText = ratio.substring(0, 5)  + "% of the states would not pass."
      }
      text(ratioText, 300, 50)
      // text("Hello", width / 2, height / 2)
      pop()
      currentSlideValue = mySlider.value()
      tableStats("NA", 20,300)
    }

    //if the value changes, update the plot 
    if (carbonSlideVal != mySlider.value()) {
      carbonSlideVal = mySlider.value()
      updateCarbonbySlider(carbonSlideVal)
    }


    if (infoPopupState) {

      //middle of the rectangle is the middle of the screen.
      size = width -2*20
      // print(width/2 - size/2)
      push()
      fill(100,100,100)
      rect(width/2 - size/2,height/2 - size/2,size,size)
      fill(255)
      lineheight = 12
      startx = width/2 - size/2 + 300
      starty = 15
      text("The built environment contributes substantial carbon emissions through concrete construction.", startx, starty)
      text("which accounts for 11% of total greenhouse gas emission.",startx, starty + lineheight)
      text("Policy makers try to mitigate the problem by limiting the amount of embodied carbon per building.", startx,starty + 2*lineheight)
      text("This project aims to raise awareness that, limiting carbon by number does not reflect how locals use their material",  startx,starty + 3*lineheight)
      text("and it might be unfair to do so. Hence, alternative, more data/region specific is needed to address the problem.",  startx,starty +4*lineheight)
      text("<<<Click anywhere to continue>>>", width - 220, 75)
    }
  }

}


function mousePressed() {
  if (infoPopupState) {
    infoPopupState = false
  }
}