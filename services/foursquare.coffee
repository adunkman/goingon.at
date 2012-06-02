express = require "express"
querystring = require "querystring"
oauth = require "oauth"
app = module.exports = express.createServer()
config = require "../config/foursquare"
rest = require "restler"

class Foursquare
   constructor: () ->
      @clientId = config.clientId
      @clientSecret = config.clientSecret
      @urls = 
         apiServer: "https://api.foursquare.com"
         server: "https://foursquare.com"
         auth: "/oauth2/authenticate"
         token: "/oauth2/access_token"
      
      @oauth = new oauth.OAuth2 @clientId, @clientSecret, @urls.server, @urls.auth, @urls.token
      @oauth.setAccessTokenName "oauth_token"

   getAuthUrl: (host) =>
      @oauth.getAuthorizeUrl 
         redirect_uri: host + "/auth/foursquare_callback"
         response_type: "code"

   authenticate: (req, code, callback) =>
      host = "http://" + req.headers.host
      @oauth.getOAuthAccessToken code, { 
         redirect_uri: host + "/auth/foursquare_callback", 
         grant_type: "authorization_code" }, 
         (error, access_token, refresh_token) ->
            return callback error if error

            @access_token = access_token
            
            req.session.foursquare = 
               access_token: access_token
               refresh_token: refresh_token

            callback null

   get: (url, data, callback) =>
      if arguments.length is 2
         callback = data
         data = {}

      data.v = "20120602"
      qs = querystring.stringify data
      
      @oauth.getProtectedResource "#{@urls.apiServer}#{url}?#{qs}", @access_token, 
         (error, data) ->
            if error then callback error
            else callback null, JSON.parse data

foursquare = new Foursquare()

app.get "/auth/foursquare", (req, res) ->
   res.redirect foursquare.getAuthUrl("http://" + req.headers.host)

app.get "/auth/foursquare_callback", (req, res, next) ->
   code = req.query.code
   error = req.query.error

   if error
      res.status 500
      res.send error
   else if code 
      foursquare.authenticate req, code, (error) -> 
         return next error if error
         res.redirect "/"

app.use (req, res, next) ->
   req.services or= {}
   req.services.foursquare = foursquare

   foursquare.access_token = req.session.foursquare?.access_token
   next()
