$(document).ready(function() {

  var socket = io.connect(window.location.origin);

  $('#watch').click(function() {
    socket.emit('location', $('#location').val());
  });

  socket.on('tweets', function (data) {
    for (x in data) {
      var tweet = data[x]
      
      console.log(tweet)
      $('#tweets').prepend($('<li/>').text(tweet.text));
    }
  });

});