
#import "tuneup/tuneup.js"
#import "canvas-ext.js"
#import "canvas-login-ext.js"
#import "canvas-screenshot-ext.js"

#import "SnapshotHelper.js"

function testLoginCancelWorks (target, app) {
     target.delay(1);
     var domainName = "mobileqa.instructure.com";
     app.enterDomain(domainName);

  // captureLocalizedScreenshot("testLoginCancelWorks")
	 createCanvasImageAsserter('./tuneup', '/tmp/snapshot_traces/', './master_screenshots/en-US');
	 assertCanvasScreenMatchesImageNamed("testLoginCancelWorks")
	 
     app.cancelLogout();
     // back out delay
     target.delay(1);
     }