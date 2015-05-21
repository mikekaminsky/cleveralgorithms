//cleveralgorithmvis.js
//Michael Kaminsky
// Needs the following data:
// search_space defines visualization size
// solution defines the optimal solution
// iterations defines the number of animation slides
// For each iteration, we need an x and a y that defines location for every point
// Process is simple: 
// Plot the 'optimum' in red
// For each iteration plot all of the points


//Load data
var data = JSONData["data"].slice()

//constants
var iterations = JSONData["metadata"]["iterations"]
var frameRate = 400 // Miliseconds between redraws
var boxLength = 1200
var spaceMin = JSONData["metadata"]["spacemin"]
var spaceMax = JSONData["metadata"]["spacemax"]
var solution = JSONData["metadata"]["solution"]

//Create container
var xScale = d3.scale.linear()
                     .domain([spaceMin, spaceMax])
                     .range([0, boxLength]);

var yScale = d3.scale.linear()
                     .domain([spaceMin, spaceMax])
                     .range([boxLength, 0]); // Browser's origin is upper left corner

//Draw box
var svg = d3.select("body").append("svg:svg")
  .attr("width", boxLength)
  .attr("height", boxLength)

//Draw gridlines
var startX = d3.min(xScale.domain()),
    endX = d3.max(xScale.domain()),
    startY = d3.min(yScale.domain()),
    endY = d3.max(yScale.domain());
var lines = [{x1: startX, x2: endX, y1: (startY + endY)/2, y2: (startY + endY)/2},
             {x1: (startX + endX)/2, x2: (startX + endX)/2, y1: startY, y2: endY}]
svg.selectAll(".grid-line")
    .data(lines).enter()
    .append("line")
    .attr("x1", function(d){ return xScale(d.x1); })
    .attr("x2", function(d){ return xScale(d.x2); })
    .attr("y1", function(d){ return yScale(d.y1); })
    .attr("y2", function(d){ return yScale(d.y2); })
    .attr("class", "grid-line")

var targetSize = xScale(spaceMin+(spaceMax - spaceMin)*.1)

//Draw Target
svg.append("rect")
  .attr("x", function(d){ return xScale(solution.x) - targetSize/2; })
  .attr("y", function(d){ return yScale(solution.y) - targetSize/2; })
  .attr("height", targetSize)
  .attr("width", targetSize)
  .attr("class", "outer-rectangle");

svg.append("rect")
  .attr("x", function(d){ return xScale(solution.x) - targetSize/10/2; })
  .attr("y", function(d){ return yScale(solution.y) - targetSize/10/2; })
  .attr("height", targetSize/10)
  .attr("width", targetSize/10)
  .attr("class", "inner-rectangle");


function drawIter(iterNumber){
  console.log(iterNumber)

  //Subset data 
  var iterdata = data.filter(function(d){
    return d.iteration == iterNumber;
  })[0]["locations"];

  //Move the dots
  dots.data(iterdata)
  .transition()
    .duration(frameRate)
    .attr("transform", function(d) { return "translate(" + xScale(d.x) + "," + yScale(d.y) + ")"; })

}

function drawTimeout(i){
  setTimeout(function() {drawIter(i); }, i * frameRate);
}

// Initialize dots
var iterdata = data.filter(function(d){
  return d.iteration == 0;
})[0]["locations"];

var dots = svg.selectAll("circle")
    .data(iterdata)
    .enter()
    .append("svg:circle")
    .attr("r", 4)
    .attr("transform", function(d) { return "translate(" + xScale(d.x) + "," + yScale(d.y) + ")"; })

for (i = 1; i <= iterations; i++) { 
  drawTimeout(i);
}
