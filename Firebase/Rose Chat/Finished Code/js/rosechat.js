// Get a reference to the root of the chat data.
var rootRef = new Firebase('https://rosechat.firebaseio.com');
var messagesRef = rootRef.child('messages');
var authClient = new FirebaseSimpleLogin(rootRef, function(error, user){
      if (error) {
        alert(error.message);
      } if (user) {
        $('#signOutButton').on('click', function() {
          console.log("User clicked logout button");
          authClient.logout();
        });
      } else {
        window.location.href = "login.html";
      }
});

$(function() { 
  // When the user presses enter on the message input, write the message to firebase.
  $('#messageInput').keypress(function (e) {
    if (e.keyCode == 13) {
      var name = $('#nameInput').val();
      var text = $('#messageInput').val();
      messagesRef.push({name:name, text:text});
      $('#messageInput').val('');
    }
  });

  // Add a callback that is triggered for each chat message.
  messagesRef.limit(10).on('child_added', function (snapshot) {
    var message = snapshot.val();
    $('<div/>').text(message.text).prepend($('<em/>')
      .text(message.name+': ')).appendTo($('#messagesDiv'));
    $('#messagesDiv')[0].scrollTop = $('#messagesDiv')[0].scrollHeight;
  });

});