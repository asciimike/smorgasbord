var authRef = new Firebase('rosechat.firebaseio.com');
var authClient = new FirebaseSimpleLogin(authRef, function(error, user) {
	if (error) {
		$('#passInput').val('');
		alert(error.message);
		return;
	} else if (user) {
		window.location.href = "rosechat.html";
	} else {
		$('#signInButton').on('click', function() {
			userLogIn($('#userInput').val(),$('#passInput').val())
		});
	}
});

var userLogIn = function(username, password){
	authClient.login('password', {
					email: username,
					password: password
					});
}

$(function(){
	$('#passInput').keypress(function (event) {
    	if (event.keyCode == 13) {
    		userLogIn($('#userInput').val(),$('#passInput').val())
    	}
  	});
});