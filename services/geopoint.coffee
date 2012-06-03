express = require "express"
app = module.exports = express.createServer()
config = require "../config/geopoint"
rest = require "restler"
crypto = require "crypto"

getClientIp =  (req) ->
   forwardedIps = req.header "x-forwarded-for"
   if forwardedIps? then forwardedIps.split(",")[0]
   else req.connection.remoteAddress

class GeoPoint
   get: (req, callback) ->
      console.log getClientIp req
      url = "http://api.quova.com/v1/ipinfo/" + getClientIp req
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
   geopoint.get req, (error, data) ->
      res.json data

app.use (req, res, next) ->
   req.services or= {}
   req.services.geopoint = geopoint
   next()