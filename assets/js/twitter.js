$(document).ready(function() {

  var socket = io.connect(window.location.origin);

  $('#watch').click(function() {
    socket.emit('location', $('#location').val());
  });

  socket.on('tweets', function (data) {
    console.log(data);
    $('#tweets').prepend($('<li/>').text(data.text));
  });

});