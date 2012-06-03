express = require "express"
app = module.exports = express.createServer()

app.get "/", (req, res) ->
   res.send "Here is a homepage."

app.get "/me", (req, res) ->
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
      res.send data

app.get "/places", (req, res, next) ->
   ll = req.query.lat+','+res.query.lon
   req.services.google.places "", { ll: ll }, 
      (error, data) ->
         return next error if error
         res.json data

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
