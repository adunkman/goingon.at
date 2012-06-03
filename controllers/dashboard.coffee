express = require "express"
app = module.exports = express.createServer()

app.get "/", (req, res) ->
   res.send "Here is a homepage."

app.get "/location/tweets", (req, res, next) ->
   lat = req.query.lat
   long = req.query.long

   req.services.twitter.getTweets lat, long, "0.25mi", (error, tweets) ->
      return next error if error
      res.json tweets

app.get "/location/instagrotos", (req, res, next) ->
   lat = req.query.lat
   long = req.query.long

   req.services.instagram.getImages lat, long, (error, photos) ->
      return next error if error
      res.json photos.data

app.get "/your/location/:lat,:long", (req, res) ->
   res.render "stream", coords: 
      lat: req.params.lat
      long: req.params.long

app.get "/foursquare", (req, res, next) ->
   req.services.foursquare.get "/v2/venues/trending", { ll: "38.980563,-94.520767" }, 
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