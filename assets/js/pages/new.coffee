ko = window.ko
socket = io.connect window.location.origin 

quotes = ['Giraffes step forward with both right legs and both left legs.',
   'Giraffes are not capable of making oral sounds. Funny that I am talking now!',
   'We have tongues as long as 19 inches!',
   'The tip of my tongue is black to prevent sunburn!',
   'I live an average of 25 to 30 years.',
   'Giraffes give birth and sleep standing up!']

pickRandomQuote = ->
   quote = 
      text: quotes[Math.floor((Math.random() * quotes.length))]
      user: { screen_name: 'poop' }

   return quote

viewModel = 
   instagrotos: ko.observable([])
   tweets: ko.observable([])
   showMenu: ko.observable(false)
   tweet: ko.observable(pickRandomQuote())
   location: ko.observable({lat: 0, lng: 0})
   address: ko.observable("");
   live_tweets: [],
   selectNextTweet: ->
      if this.live_tweets.length > 0 
         t = this.live_tweets.shift()
         this.tweet t

viewModel.strips = ko.computed () ->
   items = (_.map viewModel.instagrotos(), (instagroto) -> 
      instagroto.time = new Date instagroto.created_time * 1000
      instagroto.type = "instagroto"
      return instagroto
   ).concat(_.map viewModel.tweets(), (tweet) -> 
      tweet.time = new Date tweet.created_at
      tweet.type = "tweet"
      return tweet
   )

   _.sortBy items, (thing) -> thing.time * -1

viewModel.location.subscribe () ->
   fetchThings()

loadMap = () ->
   navigator.geolocation.getCurrentPosition (position) ->
      currentLocation = new google.maps.LatLng position.coords.latitude, position.coords.longitude

      map = new google.maps.Map document.getElementById("map_picker"), 
         center: currentLocation
         zoom: 13
         mapTypeId: google.maps.MapTypeId.ROADMAP

      circle = new google.maps.Circle
         center: currentLocation
         editable: true
         radius: 750
         map: map

      google.maps.event.addListener map, 'click', (e) ->
         map.panTo e.latLng 
         viewModel.location lat: e.latLng.lat(), lng: e.latLng.lng()
         circle.setCenter e.latLng

fetchThings = (coords) ->
   $.getJSON "/location/instagrotos", viewModel.location(), (photos) ->
      viewModel.instagrotos photos

   $.getJSON "/location/tweets", viewModel.location(), (tweets) ->
      viewModel.tweets tweets

   $.getJSON "/geocode/reverse", viewModel.location(), (address) ->
      viewModel.address address

locateThatGuyOrGirl = () ->
   if window.coords
      viewModel.location(window.coords)
   else if navigator.geolocation?
      navigator.geolocation.getCurrentPosition ( position ) ->
         viewModel.location(
            lat: position.coords.latitude, 
            lng: position.coords.longitude)
         
   else console.log "Woah man, you can't be located. You're off the grid. Mad props."

$(document).ready () ->
   ko.applyBindings viewModel
   loadMap()
   locateThatGuyOrGirl()