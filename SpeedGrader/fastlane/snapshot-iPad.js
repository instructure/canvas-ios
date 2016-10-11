#import "SnapshotHelper.js"

#import "automation_scripts/tuneup/tuneup.js"
#import "automation_scripts/canvas-ext.js"
#import "automation_scripts/canvas-login-ext.js"


#import "automation_scripts/automationTests.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(3)
captureLocalizedScreenshot("0-LandingScreen")

testLoginCancelWorks(target, app)