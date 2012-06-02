express = require "express"
app = module.exports = express.createServer()
rest = require "restler"

class GeoCode
   constructor: () ->
      @apiServer = 'http://open.mapquestapi.com/geocoding/v1/address'

   lookup: (address, callback) ->
      rest.get(@apiServer,
         query:
            inFormat: 'kvp'
            outFormat: 'json'
            thumbMaps: false
            location: address)
      .on "complete", (result) =>
         callback null, @extractResult result

   extractResult: (result) ->
      locations = result.results[0].locations

      console.log locations

      if locations.length == 0
         null
      else
         lat: locations[0].latLng.lat
         lng: locations[0].latLng.lng
         alts:
            {lat: loc.latLng.lat, lng: loc.latLng.lng} for loc in locations[1..locations.length]

geocode = new GeoCode()

app.use (req, res, next) ->
   req.services or= {}
   req.services.geocode = geocode
   next()