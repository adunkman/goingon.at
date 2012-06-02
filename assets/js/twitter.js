$(document).ready(function() {

  var socket = io.connect('http://localhost:3000');

  socket.on('tweets', function (data) {
    console.log(data);
  });

});