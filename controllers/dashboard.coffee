express = require "express"
app = module.exports = express.createServer()

app.get "/", (req, res) ->
   res.render "search"

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

app.get "/events", (req, res) ->
   res.render "events"


#=== SERVICES ===
app.get "/photos", (req, res) ->
   lat = req.query.lat
   lng = req.query.lng
   req.services.instagram.getImages lat, lng, (error, data) ->
      res.json data

app.get "/foursquare", (req, res, next) ->
   ll = req.query.lat+','+req.query.lon
   req.services.foursquare.get "/v2/venues/trending", { ll: ll }, (error, data) ->
      return next error if error
      console.log( 'foursqare return', data )
      res.json data

app.get "/places", (req, res, next) ->
   ll = req.query.lat+','+req.query.lng
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
               
app.get "/place/:name/:id", ( req, res, next ) ->
   req.services.google.places "details",
      reference: req.params.id
      (error, place) ->
         return next error if error
         p = place.result.geometry.location

         console.log place

         res.render "stream", 
            coords: { lat: p.lat, long: p.lng },
            place: 
               name: place.result.name
               website: place.result.website
               address: place.result.formatted_address
               vicinity: place.result.vicinity
               number: place.result.formatted_phone_number

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
