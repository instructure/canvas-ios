extend(UIAApplication.prototype, {
       
  enterDomain: function (domainName) {
    var window = this.mainWindow();
    var target = UIATarget.localTarget();
       
       UIALogger.logMessage("1");
    //domain information
       UIALogger.logMessage("2" + window.textFields()[0]);
	   var domainField = window.textFields().firstWithPredicate("value like 'Find your school or district'");

       UIALogger.logMessage("6" + domainField);
    domainField.setValue(domainName);
    domainField.tap();
       
    target.delay(2);
    this.keyboard().typeString("\n");
    target.delay(3);
  },
       
  enterUsernamePassword: function (username, password) {
    var window = this.mainWindow();
    var target = UIATarget.localTarget();
       
    var webView = window.scrollViews()[0].webViews()[0];
       
    // username field
    var textFields = webView.textFields();
    textFields[0].tap();
    target.delay(1);
    this.keyboard().typeString(username);
       
    // password field
    var secureTextFields = webView.secureTextFields();
    secureTextFields[0].tap();
    target.delay(1);
    this.keyboard().typeString(password);
  },
       
  cancelLogout: function () {
    var window = this.mainWindow();
    var navBar = window.navigationBar();
    navBar.buttons()["Cancel"].tap();
  },

  /**
   * A shortcut for getting the current view controller's title from the
   * navigation bar. If there is no navigation bar, this method returns null
   */
  login: function (domainName, username, password) {
  	 UIALogger.logMessage("Login: " + domainName + " : " + username + " : " + password);
  
	 this.enterDomain(domainName)
	 // delay 2 seconds for web request to return.
	 target.delay(2);
	 this.enterUsernamePassword(username, password)
  },
  
  /**
   * A shortcut for getting the current view controller's title from the
   * navigation bar. If there is no navigation bar, this method returns null
   */
  confirmLogin: function () {
 	 var window = this.mainWindow();
 	 var webView = window.scrollViews()[0].webViews()[0];
	  
	  // login
	  target.delay(1);	 
	  webView.buttons()["Log In"].tap();
 
	  // confirm
	  target.delay(2);	 
	  webView.buttons()["Log In"].tap();
  },
  
  /** 
  	 A shortcut to logout of the current application on the iPad
   */
  logoutTablet: function () {
  	this.navigationBar().buttons()["Profile"].tap();
	this.mainWindow().buttons()["Logout"].tap();
	this.mainWindow().popover().actionSheet().collectionViews()[0].cells()["Logout"].buttons()["Logout"].tap();
	target.delay(1);
  },
  
  /**
   * A shortcut to logout of the current application on the iPhone
   */
  logout: function () {
  	this.tabBar().buttons()["Profile"].tap();
	this.mainWindow().buttons()["Logout"].tap();
	this.actionSheet().collectionViews()[0].cells()["Logout"].buttons()["Logout"].tap();
	target.delay(1);
  }
});