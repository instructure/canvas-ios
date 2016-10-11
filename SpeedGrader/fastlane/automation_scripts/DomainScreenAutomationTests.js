
#import "tuneup/tuneup.js"
#import "canvas-ext.js"
#import "canvas-login-ext.js"

//test("Login page layout correct", function(target, app) {
//	 //ureLocalizedScreenshot("Login_Layout");
//});
//

test("Canvas login page cancel button works", function(target, app) {
     target.delay(1);
     var domainName = "mobileqa.instructure.com";
     app.enterDomain(domainName);
     
     app.cancelLogout();
     // back out delay
     target.delay(1);
     });

test("Login failure with incorrect domain", function(target, app) {
     target.delay(1);
     var domainName = "fake.instructure.com";
     app.enterDomain(domainName);
     
     // //ure screenshot
     //ureLocalizedScreenshot("CORRECT_LOGIN_WEBVIEW");
     
     app.cancelLogout();
     // back out delay
     target.delay(1);
});

test("Login failure with incorrect username", function(target, app) {
     target.delay(1);
     var domainName = "mobileqa.instructure.com";
     app.enterDomain(domainName);
     
     app.enterUsernamePassword("fake", "instruct");
     
     // //ure screenshot
     //ureLocalizedScreenshot("CORRECT_LOGIN_WEBVIEW");
     
     app.cancelLogout();
     // back out delay
     target.delay(1);
});

test("Login failure with incorrect password", function(target, app) {
     target.delay(1);
     var domainName = "mobileqa.instructure.com";
     app.enterDomain(domainName);
     
     app.enterUsernamePassword("s1", "fake");
     
     // //ure screenshot
     //ureLocalizedScreenshot("CORRECT_LOGIN_WEBVIEW");
     
     app.cancelLogout();
     // back out delay
     target.delay(1);
});

test("\"instructure.com\" appended to typed url", function(target, app) {
     target.delay(1);
     var domainName = "mobileqa";
     app.enterDomain(domainName);
	 
     // test the domain name text is what we expect
     var window = app.mainWindow();
	 var navBar = window.navigationBar();
	 var navBarLabel = navBar.staticTexts()[0];
	 assertEquals(navBarLabel.name(), "mobileqa.instructure.com");
	 
	 // //ure learn.canvas.net screenshot
	 //ureLocalizedScreenshot("INSTRUCTURE_APPEND");
	 
     app.cancelLogout();
     // back out delay
     target.delay(1);
});

test("Typing full URL does not append \"instructure.com\"", function(target, app) {
     target.delay(1);
     var domainName = "mobileqa.instructure.com";
     app.enterDomain(domainName);

	 // delay 3 to wait for screen to load
     var window = app.mainWindow();
	 var navBar = window.navigationBar();
	 var navBarLabel = navBar.staticTexts()[0];
	 assertEquals(navBarLabel.name(), domainName);
	 
	 // //ure learn.canvas.net screenshot
	 //ureLocalizedScreenshot("FULL_URL");
	 
     app.cancelLogout();
     // back out delay
     target.delay(1);
});

test("Canvas Login Page reduces for login (mobile sized)", function(target, app) {
     target.delay(1);
     var domainName = "mobileqa.instructure.com";
     app.enterDomain(domainName);
	 
	 // //ure screenshot
	 //ureLocalizedScreenshot("CORRECT_LOGIN_WEBVIEW");
	 
     app.cancelLogout();
	 // back out delay
	 target.delay(1);
});

test("I don't know my password functions properly", function(target, app) {
     target.delay(1);
     var domainName = "mobileqa.instructure.com";
     app.enterDomain(domainName);
	 
	 // check password
     var window = app.mainWindow();
	 var passwordResetButton = window.scrollViews()[0].webViews()[0].staticTexts()["I don't know my password"];
	 passwordResetButton.tap();
	
 	 target.delay(2);
	 //ureLocalizedScreenshot("Forgot_Password");
	 
	 // enter text and press enter
	 var webView = window.scrollViews()[0].webViews()[0];
	 
	 // username field
	 var textFields = webView.textFields();
	 textFields[0].tap();		
 	 target.delay(1);
	 app.keyboard().typeString("s1@soccerstorm.com");
	 
 	 target.delay(1);
	 window.scrollViews()[0].webViews()[0].buttons()["Request Password"].tap();	 

	 // delay 3 seconds for web request
	 target.delay(3);
	 passwordResetButton.tap();
	 
 	 target.delay(1);
	 window.scrollViews()[0].webViews()[0].staticTexts()["Back to Login"].tap();
     
     target.delay(1);
     app.cancelLogout();
     // back out delay
     target.delay(1);
	 
});


test("Canvas login page has correct user info displayed", function(target, app) {
     target.delay(1);
	 app.login("mobileqa.instructure.com", "s1", "instruct");
	 
     var window = app.mainWindow();
     var webView = window.scrollViews()[0].webViews()[0];
     
     // login
     target.delay(1);	 
     webView.buttons()["Log In"].tap();
     
	 target.delay(3);
	 //ureLocalizedScreenshot("Canvas_Login_Info");
	 
	 // cancel login
 	var navBar = window.navigationBar();
 	navBar.buttons()["Cancel"].tap();
 	
 	// back out delay
 	target.delay(1);
	 
});

test("Test Student Login", function(target, app) {	 
     target.delay(1);
	 app.studentLogin();
     app.logout();
     target.delay(1);
});


test("Test TA Login", function(target, app) {	
     target.delay(1); 
	 app.taLogin();
     app.logout();
     target.delay(1);
});

test("Test Teacher Login", function(target, app) {	 
     target.delay(1);
	 app.teacherLogin();
     app.logout();
     target.delay(1);
});

//test("Verify Login Screenshots", function(target, app) {
//	// verify screenshots match
//});
