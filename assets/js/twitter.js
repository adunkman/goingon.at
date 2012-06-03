$(document).ready(function() {

  var socket = io.connect(window.location.origin);
  var quotes = [{
      text: 'Giraffes step forward with both right legs and both left legs.',
    }, {
      text: 'Giraffes are not capable of making oral sounds. Funny that I am talking now!'
    }, {
      text: 'We have tongues as long as 19 inches!'
    }, {
      text: 'The tip of my tongue is black to prevent sunburn!'
    }, {
      text: 'I live an average of 25 to 30 years.'
    }, {
      text: 'Giraffes give birth and sleep standing up!'
    }];

  var pickRandomQuote = function() {
    var quote = quotes[Math.floor((Math.random() * quotes.length))];
    quote.user = { screen_name: 'poop' }
    return quote;
  }

  var viewModel = {
    tweet: ko.observable(pickRandomQuote()), 
    tweets: [],
    selectNextTweet: function() {
      if (this.tweets.length > 0) {
        var t = this.tweets.shift();
        this.tweet(t);
      }
      else {
        this.tweet(pickRandomQuote());
      }
    }  
  }

  setInterval(function() { viewModel.selectNextTweet(); }, 5000);

  socket.emit('location', 'new york, ny');

  socket.on('tweets', function (data) {
    viewModel.tweets = _.union(viewModel.tweets, data);
  });

  ko.applyBindings(viewModel, $('#poop')[0]);

});