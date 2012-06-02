express = require "express"
app = module.exports = express.createServer()
rest = require "restler"

class GeoCode
   constructor: () ->
      @apiServer = 'http://open.mapquestapi.com/geocoding/v1/address'
      @googleApi = 'http://maps.googleapis.com/maps/api/geocode/json'

   lookup: (address, callback) ->
      rest.get(@apiServer,
         query:
            inFormat: 'kvp'
            outFormat: 'json'
            thumbMaps: false
            location: address)
      .on "complete", (result) =>
         callback null, @extractLookupResult result

   extractLookupResult: (result) ->
      locations = result.results[0].locations

      if locations.length == 0 then null
      else
         lat: locations[0].latLng.lat
         lng: locations[0].latLng.lng
         alts:
            {lat: loc.latLng.lat, lng: loc.latLng.lng} for loc in locations[1..locations.length]

   reverse: (lat, lng, callback) -> 
      rest.get(@googleApi,
         query:
            sensor: false
            latlng: "#{lat},#{lng}")
      .on "complete", (result) =>
         callback null, @extractReverseResult result

   extractReverseResult: (result) ->
      if result.results.length == 0 then null
      else
         result.results[0].formatted_address

geocode = new GeoCode()

app.use (req, res, next) ->
   req.services or= {}
   req.services.geocode = geocode
   next()