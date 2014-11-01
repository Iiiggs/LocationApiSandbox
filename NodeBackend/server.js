var http = require('http'),
    express = require('express'),
    path = require('path');

MongoClient = require('mongodb').MongoClient,
Server = require('mongodb').Server,
CollectionDriver = require('./collectionDriver').CollectionDriver;
 
var app = express();

app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

var collectionDriver;
 
MongoClient.connect("mongodb://drone:drone1@ds063859.mongolab.com:63859/auto_flight_db", function(err, db) {
  if(!err) {
    collectionDriver = new CollectionDriver(db);
  }
  console.error(err)
});

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.bodyParser());


getData = function(callback){
  collectionDriver.count('items', function(error, count){
    if (error) { res.send(400, error); }
    else
    {
        collectionDriver.average('items', 'altitude', function(error, avgAlt){
        if (error) { res.send(400, error); }
        else
        {
            collectionDriver.average('items', 'speed', function(error, avgSpeed){
            if (error) { res.send(400, error); }
            else
            { 
                collectionDriver.average('items', 'locationAccuracy', function(error, avgLocationAccuracy){
                if (error) { res.send(400, error); }
                else
                {  
                    callback({
                      count:count, 
                      avgAlt:Math.round(avgAlt * 100) / 100,  
                      avgSpeed:Math.round(avgSpeed * 100) / 100, 
                      avgLocAcc: Math.round(avgLocationAccuracy * 100) / 100
                  })
                }
              })
            }
          })
        }
      })
    }
  })

}

app.get('/', function(req, res){
  getData(function(data){
    res.render('home', data)
  })
});

app.get('/data', function(req, res){
  getData(function(data){
    res.send(data)
  })
});

app.get('/:collection', function(req, res) { //A
   var params = req.params; //B
   collectionDriver.findAll(req.params.collection, function(error, objs) { //C
    	  if (error) { res.send(400, error); }
	      else { 
	          if (req.accepts('html')) { //E
              objs.forEach(function(obj){
                // if data has lat and lon present
                if(typeof(obj.latitude) !== 'undefined' && typeof(obj.longitude) !== 'undefined')
                {
                  // build a clickable element
                  var googleMapsLink = "http://maps.google.com/maps?q=" + obj.latitude + "," + obj.longitude
                  // add it to the objs  
                  obj.mapLink = googleMapsLink
                }
              })
    	          res.render('data',{objects: objs, collection: req.params.collection}); //F
              } else {
	          res.set('Content-Type','application/json'); //G
                  res.send(200, objs); //H
              }
         }
   	});
});

// do we need an other view to customize this?
 
app.get('/:collection/:entity', function(req, res) { //I
   var params = req.params;
   var entity = params.entity;
   var collection = params.collection;
   if (entity) {
       collectionDriver.get(collection, entity, function(error, objs) { //J
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //K
       });
   } else {
      res.send(400, {error: 'bad url', url: req.url});
   }
});

app.post('/:collection', function(req, res) { //A
    var object = req.body;
    var collection = req.params.collection;
    console.log('wirting ' + object + ' to collection ' + collection);
    collectionDriver.save(collection, object, function(err,docs) {
          if (err) { res.send(400, err); } 
          else { res.send(201, docs); } //B
     });
});

app.put('/:collection/:entity', function(req, res) { //A
    var params = req.params;
    var entity = params.entity;
    var collection = params.collection;
    if (entity) {
       collectionDriver.update(collection, req.body, entity, function(error, objs) { //B
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C
       });
   } else {
       var error = { "message" : "Cannot PUT a whole collection" };
       res.send(400, error);
   }
});

app.delete('/:collection/:entity', function(req, res) { //A
    var params = req.params;
    var entity = params.entity;
    var collection = params.collection;
    if (entity) {
       collectionDriver.delete(collection, entity, function(error, objs) { //B
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C 200 b/c includes the original doc
       });
   } else {
       var error = { "message" : "Cannot DELETE a whole collection" };
       res.send(400, error);
   }
});

app.use(function (req,res) { 
    res.render('404', {url:req.url}); 
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});