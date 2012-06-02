express = require "express"
app = module.exports = express.createServer()

app.get "/", (req, res) ->
   res.send "Here is a homepage."