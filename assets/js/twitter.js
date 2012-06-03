$(document).ready(function() {

  var socket = io.connect(window.location.origin);
  
  var viewModel = {
    tweets: ko.observableArray([]),
    tweet: ko.observable({}), 
    selectNextTweet: function() {
      if (this.tweets().length > 0) {
        var t = this.tweets.shift();
        this.tweet(t);
      }
      else {
        this.tweet({
          text: 'Did you know that giraffes have three penisai',
          user: { screen_name: 'poop' }
        });
      }
    }  
  }

  setInterval(viewModel.selectNextTweet, 5000);

  socket.emit('location', 'new york, ny');

  socket.on('tweets', function (data) {
    viewModel.tweets.push(data);
  });

  ko.applyBindings(viewModel, $('#poop')[0]);
  
});