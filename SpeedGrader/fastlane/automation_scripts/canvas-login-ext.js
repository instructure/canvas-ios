#import "canvas-ext.js"

extend(UIAApplication.prototype, {
  
  /**
   * A shortcut for getting the current view controller's title from the
   * navigation bar. If there is no navigation bar, this method returns null
   */
  studentLogin: function () {	
	 this.login("mobileqa.instructure.com", "s1", "instruct");
	 this.confirmLogin();
  },
  
  /**
   * A shortcut for getting the current view controller's title from the
   * navigation bar. If there is no navigation bar, this method returns null
   */
  teacherLogin: function () {	
	 this.login("mobileqa.instructure.com", "t1", "instruct");
 	 this.confirmLogin();
  },
  
  /**
   * A shortcut for getting the current view controller's title from the
   * navigation bar. If there is no navigation bar, this method returns null
   */
  taLogin: function () {	
	 this.login("mobileqa.instructure.com", "ta1", "instruct");
  	 this.confirmLogin();
  },
});
