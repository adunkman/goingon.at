express = require "express"
app = module.exports = express.createServer()
config = require "../config/geopoint"
rest = require "restler"
crypto = require "crypto"

class GeoPoint
   get: (ip, callback) ->
      url = "http://api.quova.com/v1/ipinfo/" + ip
      hash = crypto.createHash "md5"
      hash.update config["apiKey"], "utf8"
      hash.update config["sharedSecret"], "utf8"
      hash.update (Math.ceil (+new Date()) / 1000).toString(), "utf8"

      rest.get url, 
         query:
            apikey: config["apiKey"]
            sig: hash.digest "hex"
            format: "json"
      .on "complete", (result) ->
         if result instanceof Error
            callback(result)
         else if result.ipinfo?.Location?
            callback null, {
               lat: result.ipinfo.Location.latitude
               lng: result.ipinfo.Location.longitude
            }
         else
            callback new Error "Failed to get latitude and longitude for IP address: #{ip}"


geopoint = new GeoPoint()

# Used to test
app.get "/test/geopoint", (req, res) ->
   geopoint.get "173.118.123.199", (error, data) ->
      res.json data

app.use (req, res, next) ->
   req.services or= {}
   req.services.geopoint = geopoint
   next()