express = require 'express'
LocationStreamer = require './location_streamer'
geocode = require('./geocode').geocode
rest = require('restler')

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
    socket.emit 'tweets', [data]

fetchPastTweets = (location, callback) ->
  rest.get 'http://search.twitter.com/search.json', 
    query:
      q: '*'
      geocode: "#{location.primary.lat},#{location.primary.lng},.25km"
  .on 'complete', (data) ->
    callback null, data.results

module.exports = (io) -> 
  sockets = {}
  streamer = new LocationStreamer()

  streamer.on 'streamdata', (data) ->
    for k,v of sockets
      v.get 'location', (err, location) ->
        handleTweets v, location, data

  io.on 'connection', (socket) ->
    #get some starter tweets
    socket.on 'location', (location) ->
      if location?
        geocode.lookup location, (err, result) ->
          socket.set 'location', result
          fetchPastTweets result, (err, data) ->
            socket.emit 'tweets', data
          streamer.addLocation result         
          sockets[socket.id] = socket
      else
        delete sockets[socket.id]

    socket.on 'disconnect', ->
      delete sockets[socket.id]

  app = express.createServer()

  return registerRoutes app