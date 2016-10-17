
// ------------------------------------------------------------------------
app.setup = function() {
	createCanvas(windowWidth, windowHeight);
}

app.draw = function() {
}

app.windowResized = function() {
	resizeCanvas(windowWidth, windowHeight);
}

app.mouseDragged = function() {
}

app.mouseReleased = function() {
}

app.mousePressed = function() {
}

app.keyPressed = function() {
}


var serialPort = require("browser-serialport");

serialPort.list(function (err, ports) {
console.log(err);
  // ports.forEach(function(port) {
  //   console.log(port.comName);
  //   console.log(port.pnpId);
  //   console.log(port.manufacturer);
  // });
});
