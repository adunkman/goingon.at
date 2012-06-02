###
Street-view:
   http://maps.googleapis.com/maps/api/streetview?size=400x400&location=40.720032,%20-73.988354&fov=90&heading=235&pitch=10&sensor=false&key=AIzaSyDmvGliUS1OmEHzFE6ADNhuwO-eVQ-znsw
BOUNDS
   northeast": {
   "lat": 39.356662,
   "lng": -94.385522
   },-
   "southwest": {
   "lat": 38.827176,
   "lng": -94.765917
   }
###

express = require "express"
app = module.exports = express.createServer()
_ = require "underscore"
rest = require "restler"
config = require "../config/google"


class Google
   constructor: () ->
      # do some junk
      console.log "Google.constructor"
   
   get: ( url, data, callback ) ->
      console.log "Google.get", { url:url, data:data }
      rest.get( url, data )
      .on "complete", (result) ->
         console.log JSON.stringify( result )
         if result instanceof Error then callback(result)
         else callback(null, result)
   
   places: ( callType, params, callback ) ->
      url = config.base_url+'/'+callType+'/json'
      switch callType
         when "search" then defaults = config.placeSearch.defaults
         when "detail" then defaults = config.placeDetails.defaults
         else null
      params = _.extend defaults, {key: config.key}, params
      
      this.get url, 
         query: params, 
         (error, data) ->
            callback error, data
      
google = new Google()

# Used to test place search
app.get "/test/place/search", (req, res) ->
   google.places "search",
      location: "38.980563,-94.520767"
      radius: 500,
      (error, data) ->
         res.json data

# Used to test place detail (heartland golf club)
app.get "/test/place/detail", (req, res) ->
   google.places "detail",
      reference: "CoQBcQAAAHXNoLhdfwWkY7tAGxGMP99BlmkehiyWq_Osp9iaXAc1ftKKCgKMnix9sZvUb6Rr6V_l6o7vVtNLeuEiY021IQpaED1ODdiYq84wS9qmWMz4wxbUs0EvEF7_1yDaHL-OlRO4o85JVYTe4I2He9iFPPzvoqnX8eioxk4eIUCRjsJ5EhBssDOwawwlVlnY49SqBbEoGhSGnaQyUMBe_9y6cN-dSqIAxRSNFg",
      (error, data) ->
         res.json data


app.use (req, res, next) ->
   # Your middleware peice
   #keys = req.session.services?.google
   #google.access_token = keys?.access_token
   req.services or= {}
   req.services.google = google
   next();
