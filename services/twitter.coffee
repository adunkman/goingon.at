twitter = require 'ntwitter'
express = require 'express'
LocationStreamer = require './location_streamer'

sanfran = '-122.75,36.8,-121.75,37.8'
heartland = '-94.541016,38.973021,-94.5084,38.983876'

locationStreamer = new LocationStreamer()

registerRoutes = (app) ->
  app.get '/test/twitter', (req, res) ->
    res.render 'twitter'  
  return app

resolveLocation = (location) ->
  if location == 'kansas city'
    return heartland
  return sanfran

module.exports = (io) -> 
  io.on 'connection', (socket) ->
    socket.on 'location', (location) ->
      l = resolveLocation location
      
      locationStreamer.addLocation l

      locationStreamer.on 'data', (data) ->
        socket.emit 'tweets', data

  app = express.createServer()

  return registerRoutes app