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

handleTweets = (socket, location, tweets) ->
  
  console.log tweets

  #what is tweets?

  point = 
    x: data.geo.coordinates[0]
    y: data.geo.coordinates[1]

  bounds = 
    bottom_left: 
      x: location.boundingBox.southwest.lng
      y: location.boundingBox.southwest.lat
    top_right: 
      x: location.boundingBox.northeast.lng
      y: location.boundingBox.northeast.lat

  if isWithinBounds bounds, point
    socket.emit 'tweets', data


module.exports = (io) -> 
  clients = []
  streamer = new LocationStreamer()

  io.on 'connection', (socket) ->
    callback = (data) ->
      for client in clients
        client.get 'location', (location) ->
          handleTweets socket, location, data

    streamer.on 'data', callback

    socket.on 'location', (location) ->
      socket.set 'location', location

      if location?
        geocode.lookup location, (err, result) ->
          streamer.addLocation location
          if clients.indexOf socket == -1
            clients.push socket
      else
        clients.remove socket
    
    socket.on 'disconnect', ->
      clients.remove socket
      #need to stop monitoring location if there's nobody interested.

  app = express.createServer()

  return registerRoutes app