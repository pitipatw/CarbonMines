function stddev(arr) {
  let avg = arr.reduce((acc, c) => acc + c, 0) / arr.length;
  let variance = arr.reduce((acc, c) => acc + (c - avg) ** 2, 0) / arr.length;
  return sqrt(variance);
}


function mean(arr) {
    let avg = arr.reduce((acc, c) => acc + c, 0) / arr.length;
    return avg
  }


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

function drawIntro(){
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
  // myOver.style('padding', "10px")
  myOver.style('font-size', "18px")
  myOver.style('background-color', 'green'); // Color of the rectangle
  myOver.style('border', '2px solid black'); // Optional border
  myOver.style("z-index", "9998")
  myOver.style("opacity", 0.75);
}


function findClosestStates(carboni) {
  // Copy the original array of states with carbon emissions
  let sortedStates = dictCarbonState.slice();

  // Sort states based on the absolute difference in carbon emissions compared to carboni
  sortedStates.sort((a, b) => {
    const diffA = Math.abs(a.Carbon - carboni);
    const diffB = Math.abs(b.Carbon - carboni);
    // print(diffA)
    return diffA - diffB; // Sort by ascending difference
  });

  // Filter out the selected state and get the top 4 closest states
  let closestStates = sortedStates.slice(0, 4); // Take the next 4 elements after the first (closest) state

  return closestStates;
}