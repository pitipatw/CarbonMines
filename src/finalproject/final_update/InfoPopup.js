function infoPopup(){

    let padding = 10;
    //middle of the rectangle is the middle of the screen.
    size = width -2*padding

    push()
    fill(100,100,100)
    rect(width/2 - size/2,height/2 - size/2,size,size)
    fill(255)
    lineheight = 12
    startx = 15
    starty = 15
    text("The built environment contributes substantial carbon emissions through concrete construction,", startx, starty)
    text("which accounts for 11% of total greenhouse gas emission.",startx, starty + lineheight)
    text("Policy makers try to mitigate the problem by limiting the amount of embodied carbon per building.", startx,starty + 2*lineheight)
    text("This project aims to raise awareness that, limiting carbon by number does not reflect how locals use their material and it might be unfair to do so.",  startx,starty + 3*lineheight)
    text("Hence, alternative, more data/region specific is needed to address the problem.",  startx,starty +4*lineheight)
    text("<<<Click anywhere to continue>>>", width - 220, 75)
}


