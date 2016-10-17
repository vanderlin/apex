var express = require('express');
var app = express();
var port = process.env.PORT || 3000;

app.set('port', port);
app.use(express.static(__dirname + '/app'));
app.set('views', __dirname + '/app');

app.listen(port);
console.log("open http://localhost:"+port);