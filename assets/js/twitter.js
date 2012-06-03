$(document).ready(function() {

  var socket = io.connect(window.location.origin);
  
  var pickRandomQuote = function() {
    return {
      text: 'Did you know that giraffes have three penisai',
      user: { screen_name: 'poop' }
    };
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