express = require "express"
app = module.exports = express.createServer()

app.get "/test/staticImage", (req, res) ->
   res.render 'test/staticImage'