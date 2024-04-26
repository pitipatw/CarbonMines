let worldMap;

let clickedState = "";
let clickedStateShape = ""; 
let oldClickedStateShape ;
// let clickedStateId = ""; 
let carbon = [];
let currentColor = [];

let carboni;
let minCarbon = 10000;
let maxCarbon = 0;

let loaded = false ;
let availableStates = [];


let mySelect; 
let mySlider; 
let myCheckbox1;
let myCheckbox2;
let myCheckbox3; 

function setup() {
  createCanvas(800, 480);
  background(224);

  // If you change the dimensions, the aspect ratio will stay the same.
  // The browser will size the map to use as much of the width/height as possible.
  let mapWidth = width * 0.8;  // use 80% of the sketch size
  let mapHeight = height * 0.8;
  // Center the map on the screen. The mapX and mapY
  // coordinates are relative to the sketch location.
  let mapX = (width - mapWidth) / 2;
  let mapY = (height - mapHeight) / 2;

  // let mapPath = "data/world-robinson.svg";
  //let mapPath = "data/world-equirectangular.svg";
  //let mapPath = "data/us-counties.svg";
  let mapPath = "data/us-states.svg";
  let stateCarbonPath = "data/statecarbon.json"

  //load the dataset

  // This will create a new SVG map from the 'robinson.svg' file in the data folder.
  // Once the map has finished loading, the mapReady() function will be called.
  worldMap = new SimpleSVG(mapPath, mapX, mapY, mapWidth, mapHeight, mapReady);
  stateCarbon = loadJSON(stateCarbonPath, dataLoaded)

  mySelect = createSelect();
  mySelect.position(width-150, height-100);
  mySelect.option("States");
  mySelect.option("Company");
  mySelect.style('border-radius', '3px');
  mySelect.style('width', '200px');
  mySelect.style('padding', '0.5em');



  mySlider = createSlider(0, 700);
  mySlider.position(width/2-200, height-30)
  mySlider.size(300)

  myCheckbox1 = createCheckbox("Office");
  myCheckbox2 = createCheckbox("Warehouse");
  myCheckbox3 = createCheckbox("Residential");

  myCheckbox1.position(width-100,height/2)
  myCheckbox2.position(width-100,height/2-50)
  myCheckbox3.position(width-100,height/2-100)



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
}

function dataLoaded(data){
  sessions = data; 
  for (let i = 1; i < sessions.length ; i++){
    availableStates.push(sessions[i].State)
    thisCarbon = sessions[i].Carbon
    carbon.push(thisCarbon)
    if (thisCarbon > maxCarbon){ 
      maxCarbon = thisCarbon
    }

    if (thisCarbon < minCarbon){
      minCarbon = thisCarbon
    }
    // print(sessions[i].State)
    worldMap.setFill(sessions[i].State, 'green');
  }
  loaded = true
}

function mapClick(shape) {
  if (!ignoreShape(shape.id)) {
    // worldMap.setFill(shape, 'red');
  //prevent error from the first run
    oldClickedStateShape = clickedStateShape
    
      //reset the color to normal (only 1 state can be clicked at a time)
    if (availableStates.includes(oldClickedStateShape.id)){
      worldMap.setFill(oldClickedStateShape, 'green');
    }
    // else{
    //   if (oldClickedStateShape != ""){
    //       worldMap.setFill(oldClickedStateShape, '#ccc');
    //   }
    // }

    if (availableStates.includes(shape.id)) {
      clickedStateShape = shape
      worldMap.setFill(clickedStateShape, 'red');
    }

  //compare carbon and highlight
    currentCarbon = carbon[availableStates.indexOf(clickedStateShape.id)]
    // print(carbon)
    // print(currentCarbon)
    marked = []
    //loop one by one, if larger, mark it 
    for (let i = 1; i < sessions.length ; i++){
      carboni = carbon[i]
      if (carboni >= currentCarbon){
        marked.push(availableStates[i])
      }
      }
  allStates = worldMap.listShapes()
  print(marked)
  for (let i = 1; i < allStates.length ; i++){
    if (marked.includes(allStates[i])) {
      print("Orange")
      //HERE, find a way to loop through other shapes in the list, not sure where to get that
    }
    }
  }
  
  print(`click ${shape.id}`);
}

// function compareCarbon(something){
//   //get the carbon value of the select map

//   //go through every list of color of shapes, then assign values based on
//   //wether the carbon of that state is higher or lower than that of the selected state.
// }

function mapOver(shape) {
  if (!ignoreShape(shape.id)) {
    if (availableStates.includes(shape.id)){
      worldMap.setFill(shape, 'gold')
    }
  else{
    worldMap.setFill(shape, '#666');
  }

  if (clickedStateShape.id == shape.id) {
    //dark read
    worldMap.setFill(shape,'#8B0000' )
  }
  print(`over ${shape.id}`);
}
}

function mapOut(shape) {
  if (!ignoreShape(shape.id)) {
    // darkgrey
    worldMap.setFill(shape, '#ccc');
    // worldMap.setFill(shape, 'red');
    // worldMap.setFill(shape, '#666')


  if (availableStates.includes(shape.id)){
    worldMap.setFill(shape, 'green')
    if (shape.id == clickedStateShape.id) {
      worldMap.setFill(shape, 'red');
    }
  }
  }
    


  print(`out ${shape.id}`);
}


// returns 'true' if this shape should be ignored
// i.e. if it's the ocean or it's the boundary lines between states
function ignoreShape(name) {
  return (name === 'ocean' || name.startsWith('lines-'));
}

function colorMapByCarbon(value){
  // again, have to loop each one and and compare, check


}




function draw() {
  // Your sketch can go here, but keep in mind that the map will always be on top.
  // showClickedStates(clickedStates)
  // background(255)
  if (!loaded){
    textAlign(CENTER,CENTER);
    text("Loading "+ frameCount, width-100, height-10)
  }
  else{
    background(255)
    text("DONE", width-100, height-10)
    text(minCarbon, width/2-200, height-30)
    text(maxCarbon, width/2+100, height-30)
    text(mySlider.value(), width/2-50, height-30)
    colorMapByCarbon(mySlider.value())

    // if (myCheckbox1.checked()) {
    //   background(255);
    // } else {
    //   background(0);
    // }

  }

}
