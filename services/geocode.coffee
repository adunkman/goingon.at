express = require "express"
app = module.exports = express.createServer()
rest = require "restler"

class GeoCode
   constructor: () ->
      @apiServer = 'http://open.mapquestapi.com/geocoding/v1/address'
      @googleApi = 'http://maps.googleapis.com/maps/api/geocode/json'

   lookup: (address, callback) ->
      rest.get(@googleApi,
         query:
            address: address
            sensor: false)
      .on "complete", (result) =>
         callback null, @extractLookupResults result

   extractLookupResults: (results) ->
      results = results.results
      console.log results
      if results.length == 0 then null
      else 
         primary: @extractLookupResult(results[0])
         alts:
            @extractLookupResult(result) for result in results[1..results.length]

   extractLookupResult: (result) ->
      address: result.formatted_address
      lat: result.geometry.location.lat
      lng: result.geometry.location.lng
      boundingBox:
         northeast:
            lat: result.geometry.viewport.northeast.lat
            lng: result.geometry.viewport.northeast.lng
         southwest:
            lat: result.geometry.viewport.southwest.lat
            lng: result.geometry.viewport.southwest.lng

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