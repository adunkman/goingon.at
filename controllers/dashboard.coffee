express = require "express"
app = module.exports = express.createServer()

app.get "/", (req, res) ->
   res.send "Here is a homepage."

app.get "/foursquare", (req, res, next) ->
   req.services.foursquare.get "/v2/venues/trending", { ll: "38.980563,-94.520767" }, 
      (error, data) ->
         return next error if error
         res.json data