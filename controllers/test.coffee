express = require "express"
app = module.exports = express.createServer()

app.get "/test/staticImage", (req, res) ->
   res.render 'test/staticImage'
   
# Used to test place search
app.get "/test/place/search", (req, res) ->
   req.services.google.places "search",
      location: "38.980563,-94.520767"
      (error, data) ->
         res.json data

# Used to test place detail
app.get "/test/place/detail/:reference", (req, res) ->
   reference =  req.params.reference
   req.services.google.places "detail",
      reference: reference,
      (error, data) ->
         res.json data

