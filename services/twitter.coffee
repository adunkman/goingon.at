twitter = require('ntwitter')
express = require "express"
app = module.exports = express.createServer()

options = 
  consumer_key: 'c3NNk6syXwUqbgwKirtK1w'
  consumer_secret: 'PBR0IHNxp75W2LV2ThRqy1NeJCepJRMhlWJgQBEgk'
  access_token_key: '237468953-QaRypb0kOJ0wG3a9f1kHuyVvmIbbawU2axOPJW7S'
  access_token_secret: 'tAAYDfR7EWDD6FVE5mvVedcISThv5LB3t6RTkBwt0' 

heartland = { northeast:  
    lat: 38.983876
    lng: -94.5084,
  southwest: 
    lat: 38.973021
    lng: -94.541016
}

loc_param = heartland.southwest.lng + ',' + heartland.southwest.lat + ',' + heartland.northeast.lng + ',' + heartland.northeast.lat

t = new twitter(options)

io = require('socket.io').listen(app)

io.on 'connection', (socket) ->
  socket.on 'location', (location) ->
    console.log location

app.get '/test/twitter', (req, res) ->
  res.render 'twitter'
  
t.stream 'statuses/filter', locations: loc_param, (s) ->
  s.on 'data', (data) ->  
    console.log data

