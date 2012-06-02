express = require "express"
app = module.exports = express.createServer()

app.get "/test/staticImage", (req, res) ->
   res.render 'test/staticImage'
   
# Used to test place search
app.get "/test/place/search", (req, res) ->
   req.services.google.places "search",
      location: "38.980563,-94.520767"
      radius: 500,
      (error, data) ->
         res.json data

# Used to test place detail
app.get "/test/place/detail", (req, res) ->
   ref = "CoQBdAAAACNDYg-3kgNlLzmbkfopDH72c08l9o8GAjn_GgHavm8xMjekNC-ty01Hb1Uul0KvoWDc6BVu2VJ2-1bFS73tb8xHfEZFKEdhyHMCIcQaIVMR0caY8pSHNtVonRHhV2-a6Z9NGB743biUkxaDOpcLuWQ_d5TpVWJP0vaOORibYDTPEhAu2TD-haHn0OaVS7kulTFXGhT1jHlJtSiaWMp6h4Hnm3Mc42tiRg"
   req.services.google.places "detail",
      reference: ref,
      (error, data) ->
         res.json data

