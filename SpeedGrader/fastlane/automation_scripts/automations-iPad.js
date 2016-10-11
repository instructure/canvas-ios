#import "SnapshotHelper.js"

#import "tuneup/tuneup.js"
#import "canvas-ext.js"
#import "canvas-login-ext.js"


#import "automationTests.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(3)

testLoginCancelWorks(target, app)