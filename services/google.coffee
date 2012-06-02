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
      url = this.config.base_url+"/"+callType+"/json"
      #url = "http://shitfuck.com/"+callType+"/json"
      switch callType
         when "search" then defaults = this.config.placeSearch.defaults
         when "detail" then defaults = this.config.placeDetails.defaults
         else null
      params = _.extend defaults, {key: this.config.key}, params
      this.get url, 
         query: params, 
         (error, data) ->
            result = {error:error, url:url, params:params, data:data }
            callback error, result

google = new Google()
app.use (req, res, next) ->
   # Your middleware peice
   #keys = req.session.services?.google
   #google.access_token = keys?.access_token
   req.services or= {}
   req.services.google = google
   next();
