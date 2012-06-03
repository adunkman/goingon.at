express = require 'express'
LocationStreamer = require './location_streamer'
geocode = require('./geocode').geocode

registerRoutes = (app) ->
  app.get '/test/twitter', (req, res) ->
    res.render 'twitter'     
  return app

isWithinBounds = (bounds, p) ->
  withinX = p.x <= bounds.top_right.x && p.x >= bounds.bottom_left.x
  withinY = p.y <= bounds.top_right.y && p.y >= bounds.bottom_left.y

  return withinX && withinY

handleTweets = (socket, location, data) ->

  if !data.geo 
    return

  point = 
    x: data.geo.coordinates[1]
    y: data.geo.coordinates[0]

  bounds = 
    bottom_left: 
      x: location.primary.boundingBox.southwest.lng
      y: location.primary.boundingBox.southwest.lat
    top_right: 
      x: location.primary.boundingBox.northeast.lng
      y: location.primary.boundingBox.northeast.lat

  if isWithinBounds bounds, point
    socket.emit 'tweets', data

module.exports = (io) -> 
  sockets = {}
  streamer = new LocationStreamer()

  io.on 'connection', (socket) ->

    streamer.on 'streamdata', (data) ->
      
      console.log data

      for k,v of sockets
        v.get 'location', (err, location) ->
          handleTweets v, location, data

    socket.on 'location', (location) ->

      if location?
        geocode.lookup location, (err, result) ->
          socket.set 'location', result
          streamer.addLocation result         
          sockets[socket.id] = socket
      else
        delete sockets[socket.id]


    socket.on 'disconnect', ->
      #need to stop monitoring location if there's nobody interested.

  app = express.createServer()

  return registerRoutes app