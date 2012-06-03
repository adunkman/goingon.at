express = require "express"
app = module.exports = express.createServer()

app.get "/", (req, res) ->
   res.send "Here is a homepage."

app.get "/events", (req, res) ->
   res.render "events"


#=== SERVICES ===
app.get "/photos", (req, res) ->
   lat = req.query.lat
   lon = req.query.lon
   req.services.instagram.getImages lat, lon, (error, data) ->
      res.json data

app.get "/foursquare", (req, res, next) ->
   ll = req.query.lat+','+req.query.lon
   req.services.foursquare.get "/v2/venues/trending", { ll: ll }, (error, data) ->
      return next error if error
      console.log( 'foursqare return', data )
      res.json data

app.get "/places", (req, res, next) ->
   ll = req.query.lat+','+req.query.lon
   req.services.google.places "search",
      location: ll
      (error, data) ->
         res.json data

app.get "/places/details/:id", (req, res, next) ->
   reference = req.params.id
   req.services.google.places "details",
      reference: reference
      (error, data) ->
         res.json data.result
         
app.get "/places/search/:address", (req, res, next) ->
  req.services.geocode.lookup req.params.address, 
      (error, data) ->
         return next error if error
         location = [ data.primary.lat, data.primary.lng ]
         req.services.google.places "search",
            location: location.join ','
            (error, result) ->
               res.json result

app.get "/geocode/:address", (req, res, next) ->
	req.services.geocode.lookup req.params.address, 
		(error, data) ->
			return next error if error
			res.json data


app.get "/geocode", (req, res, next) ->
	req.services.geocode.reverse "38.980563", "-94.520767",
		(error, data) ->
			return next error if error
			res.json data
