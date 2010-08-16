/*

	who  : Jake
	when : June 14, 2007
	why  : 
			class: default
				To allow input text fields to be used without labels.
				The field shows the "id" until the user has changed it.
			class: password
				Converts the field to a "password" once the user has entered one.
				Converts the field back to a "text" if empty.

*/

Event.observe(window, 'load', function() {
	$$('input.default').each( 
		function(myinput) {
			if ( myinput.className.match( 'password' ) ) {
				myinput.type = 'text';
			}
			myinput.value = myinput.id;

			Event.observe( myinput, 'blur', 
				function(event){ 
					if ( myinput.value == "" ) {
						myinput.value = myinput.id;
						if ( myinput.className.match( 'password' ) ) {
							myinput.type = 'text';
						}
					}
				}
			);

			Event.observe( myinput, 'focus', 
				function(event){ 
					if ( myinput.value == myinput.id ) {
						if ( myinput.className.match( 'password' ) ) {
							myinput.type = 'password';
						}
						myinput.value = "";
					}
				}
			);

		}
	);
});

