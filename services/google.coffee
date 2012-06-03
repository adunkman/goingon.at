express = require "express"
app = module.exports = express.createServer()
_ = require "underscore"
rest = require "restler"
config = require "../config/google"

class Google
   
   constructor: () ->
      # do some junk
      this.config = config
   
   get: ( url, data, callback ) ->
      rest.get( url, data )
      .on "complete", (result) ->
         if result instanceof Error then callback(result)
         else callback(null, result)
   
   places: ( callType, params, callback ) ->
      conf = this.config;
      url = conf.base_url+"/"+callType+"/json"
      switch callType
         when "search"
            defaults = _.clone( conf.placeSearch.defaults )
            defaults.types = defaults.types.join '|' 
         when "details" then defaults = conf.placeDetails.defaults
         else null
         
      params = _.extend defaults, {key: this.config.key}, params
      console.log "url = "+url,  params
      
      this.get url, 
         query: params, 
         (error, data) ->
            callback error, data

google = new Google()
app.use (req, res, next) ->
   # Your middleware peice
   #keys = req.session.services?.google
   #google.access_token = keys?.access_token
   req.services or= {}
   req.services.google = google
   next();
