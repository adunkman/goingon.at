express = require "express"
app = module.exports = express.createServer()
config = require "../config/instagram"
rest = require "restler"

class Instagram
   get: (url, data, callback) ->
      url = config["base-url"] + (if url.substring(0,1) == "/" then url else "/#{url}")
      rest.get(url, data)
      .on "complete", (result) ->
         if result instanceof Error then callback(result)
         else callback(null, result)

   getImages: (lat, lng, range, callback) ->
      if arguments.length < 4
         callback = arguments[2]
         range = config["search-radius"]

      @get config["media-search"],
         query:
            lat: lat
            lng: lng
            client_id: config["client-id"]
            distance: range
         (error, data) ->
            callback error, data

instagram = new Instagram()

# Used to test
app.get "/test/instagram", (req, res) ->
   instagram.getImages 38.980563, -94.520767, (error, data) ->
      res.json data

app.use (req, res, next) ->
   req.services or= {}
   req.services.instagram = instagram
   next()