var authRef = new Firebase('rosechat.firebaseio.com');
var authClient = new FirebaseSimpleLogin(authRef, function(error, user) {
	if (error) {
		alert(error.message);
		return;
	} else if (user) {
		window.location.href = "rosechat.html";
	} else {
		$('#signInButton').on('click', function() {
			console.log("Sign in button clicked");
			authClient.login('password', {
					email: $('#userInput').val(),
					password: $('#passInput').val()
					});
			});
	}
});