express = require "express"
port = process.env.PORT || 3000
app = express.createServer()

# Middleware
app.use express.cookieParser()
app.use express.session secret: "aksdf2342awjefna3fnoiasdfojasofoadngfiha34isfh"
app.use require("connect-assets")()

# Services
app.use require "../services/instagram"

# Controllers
app.use require "./dashboard"

app.listen port
console.log "goingon.at listening on #{port}"