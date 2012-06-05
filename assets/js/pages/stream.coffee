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

fetchThings = (coords) ->
   $.getJSON "/location/instagrotos", coords, (photos) ->
      viewModel.instagrotos photos

   $.getJSON "/location/tweets", coords, (tweets) ->
      viewModel.tweets tweets

$(document).ready () ->
   ko.applyBindings viewModel

   setInterval ->
      viewModel.selectNextTweet()
   , 7500

   socket.emit 'location', "#{window.coords.lat},#{window.coords.long}"

   socket.on 'tweets', (data) -> 
      viewModel.live_tweets = _.union viewModel.live_tweets, data

   fetchThings(window.coords)