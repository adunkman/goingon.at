$(document).ready(function() {

  var socket = io.connect(window.location.origin);

  $('#watch').click(function() {
    socket.emit('location', $('#location').val());
  });

  $('#stop').click(function() {
    socket.emit('location', null);
  });

  socket.on('tweets', function (data) {
    $('#tweets').prepend($('<li/>').text(data.text));
  });

});