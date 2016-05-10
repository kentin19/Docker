var express = require('express'),
http = require('http'),
math = require('mathjs'),
redis = require('redis');

var app = express();

// Constants
var PORT = 8080;

// App
var app = express();

app.get('/', function(req, res){

// create a sparse matrix
var a = math.eye(3000, 3000, 'sparse');

// do operations with a sparse matrix
var b = math.multiply(a, a);
var c = math.multiply(b, math.complex(2, 2));
var d = math.transpose(c);
var e = math.multiply(d, a);

res.send('Operations done on spase matrix 3000x3000');

});

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);






