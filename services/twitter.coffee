express = require 'express'
LocationStreamer = require './location_streamer'
geocode = require('./geocode').geocode
rest = require('restler')

class Twitter 
  getTweets: (lat, long, range, callback) ->
    if arguments.length < 4
      callback = arguments[2]
      range = ".25mi"

    rest.get 'http://search.twitter.com/search.json', 
      query:
        q: '*'
        geocode: "#{lat},#{long},#{range}"
    .on 'complete', (data) ->
      if (data instanceof Error)
        callback data, []
      else
        callback null, data.results

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

  #if isWithinBounds bounds, point
  socket.emit 'tweets', [data]

module.exports = (io) -> 
  sockets = {}
  streamer = new LocationStreamer()

  streamer.on 'streamdata', (data) ->
    for k,socket of sockets
      socket.get 'location', (err, location) ->
        handleTweets socket, location, data

  io.on 'connection', (socket) ->
    socket.on 'location', (location) ->
      if location?
        geocode.lookup '8200 hillcrest, kansas city mo', (err, result) ->
          socket.set 'location', result
          streamer.addLocation result         
          sockets[socket.id] = socket
      else
        delete sockets[socket.id]

    socket.on 'disconnect', ->
      delete sockets[socket.id]

  app = express.createServer()

  app.get '/test/twitter', (req, res) ->
    res.render 'twitter'

  app.use (req, res, next) ->
    req.services or= {}
    req.services.twitter = new Twitter()
    next()

  return app