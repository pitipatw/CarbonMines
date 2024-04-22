const originx = 35;
const originy = 0;
const farx = 365;
const fary = 400;
const division = (farx-originx)/3
const midx = originx + division/2
const midy = (fary-originy)/2
const r = 200;
const gap = 30;
const xspeed = 0.9
const yspeed = 0.9
let bugs = [];

function setup() {
  createCanvas(400, 400);
    for (let i = 0; i < twelveHour(); i++) {
    bugs.push(new Jitter());
  }
  textAlign(CENTER,CENTER)
  textSize(50)
}


function draw() {
  if (meridiem() == "am") {
    background('rgb(255,187,0)');
  } else {
    background("rgb(0,140,155)");
  }
  watchMask()
  
  if ((minute() == 60) && (second() == 60)){
    let bugs = []
    for (let i = 0; i < twelveHour(); i++) {
      bugs.push(new Jitter());
    }
  }
  
  
// background('rgb(255,187,0)');
  if (smoothSecond() == 0) {
    let bugs = [];
    for (let i = 0; i < minute(); i++) {
      bugs.push(new Jitter());
    }
  }

  for (let i = 0; i < bugs.length; i++) {
    bugs[i].move();
    bugs[i].display();
  }

  
  // text(smoothSecond(), width/2, height/2)
  checkEdges()
  watchTime()
}


function checkEdges(){
  push();
  stroke(100)
  fill(100)
  circle(originx, originy, 10)
  circle(originx, fary, 10)
  circle(farx ,originy,10)
  circle(farx, fary,10)
  
  line(originx, originy, originx, fary)
  line(originx, originy, farx, originy)
  line(farx, originy, farx, fary)
  line(originx, fary, farx, fary)
  pop();
  

}

class Jitter {
  constructor() {
    this.x = random(farx-originx-2*gap);
    this.y = random(fary-originy-2*gap);
    this.diameter = random(10, 30);
    this.speed =0.005;
    this.s = random(2*PI);
    this.xdirection = random()
    this.ydirection = random()
  }

  move() {
    this.speed = smoothSecond()/100;
    
    if (smoothSecond() > 55) {
      this.speed = smoothSecond()/5;
    }
    this.diameter = 20+smoothSecond()/2;
    this.x += random(-this.speed, this.speed);
    this.y += random(-this.speed, this.speed);
    
    while (this.x + this.diameter/2 > 400) {
      this.x += random(-this.speed, this.speed);
    }
    while (this.x + this.diameter/2 < 0) {
      this.x += random(this.speed, this.speed);
    }
    while (this.y + this.diameter/2 > 400) {
      this.y += random(-this.speed, this.speed);
    }
    while (this.y + this.diameter/2 < 0) {
      this.y += random(this.speed, this.speed);
    }
    // if (abs(newx)+this.diameter/2 == 400) {
    //   this.x += random(-this.speed, this.speed);
    //   this.y += random(-this.speed, this.speed);
    // }
    this.x = this.x + xspeed * this.xdirection;
    this.y = this.y + yspeed * this.ydirection;
    if (this.x > width - this.diameter || this.x < this.diameter) {
    this.xdirection *= -1;
    }
    if (this.y > height - this.diameter || this.y < this.diameter) {
    this.ydirection *= -1;
    }
    // }
  }

  display() {
    push();
    translate(originx, originy)
    // noStroke();
    let b = map(smoothSecond(), 0, 60, 0, 100);
    colorMode(HSB);
    if (meridiem() == "am") {
      fill(0, 100, b);
    } else {
      fill(184, 85, b);
    }
          // fill(0, 100, b);
    
    for (let i = 0; i < minute(); i++) {
      let a = this.s+ TAU/60*minute();
      push();
      // line(this.x,this.y, this.x+this.diameter, this.y)
      setLineDash([2, 2]); //another dashed line pattern
      line(this.x,this.y, this.x+this.diameter*cos(this.s), this.y+this.diameter*sin(this.s))
      line(this.x,this.y, this.x+this.diameter*cos(a), this.y+this.diameter*sin(a))
      // arc(this.x, this.y, this.diameter, this.diameter, this.s, a - this.s );
      pop();
      push();
      fill(0,100,100)
      circle(this.x,this.y, this.diameter/1.5)
      fill(210,100,100)
      circle(this.x+this.diameter*cos(this.s), this.y+this.diameter*sin(this.s), this.diameter/2)
      circle(this.x+this.diameter*cos(a), this.y+this.diameter*sin(a), this.diameter/2)
      pop();
      
    }
    pop();
  }
}


function setLineDash(list) {
  drawingContext.setLineDash(list);
}


