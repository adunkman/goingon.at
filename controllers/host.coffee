express = require "express"
port = process.env.PORT || 3000
app = express.createServer()

# Settings
app.set "view engine", "jade"
app.set "view options", { layout: false }

app.configure "development", () ->
   app.use express.logger "dev"
   app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure "production", () ->
   app.use express.errorHandler()

# Middleware
app.use express.cookieParser()
app.use express.session secret: "aksdf2342awjefna3fnoiasdfojasofoadngfiha34isfh"
app.use require("connect-assets")()
app.use express.static __dirname + "/../public"

io = require('socket.io').listen(app)

io.configure 'development', () ->
  io.set 'log level', 1

# Services
app.use require "../services/instagram"
app.use require "../services/foursquare"
app.use require("../services/twitter")(io)
app.use require "../services/geocode"

# Controllers
app.use require "./dashboard"
app.use require "./test"

app.listen port
console.log "goingon.at listening on #{port}"