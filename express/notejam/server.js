#!/usr/bin/env node
var debug = require('debug')('notejam');
var app = require('./app');

//const http = require('http');

//const server = http.createServer((req, res) => {
//  res.statusCode = 200;
  //res.setHeader('Content-Type', 'text/plain');
 // res.end('Hello World');
//});

//server.listen(port, hostname, () => {
 // console.log(`Server running at http://${hostname}:${port}/`);
//});

app.set('port', process.env.PORT || 3000);

var server = app.listen(app.get('port'), function() {
  debug('Express server listening on port ' + server.address().port);
});
