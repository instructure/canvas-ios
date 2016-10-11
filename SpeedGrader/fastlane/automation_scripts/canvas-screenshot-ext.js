
#import "SnapshotHelper.js"

var CanvasImageAsserter = (function() {

  function CanvasImageAsserter(tuneUpPath, outputPath, refImagesPath) {
    if (!outputPath || !refImagesPath || !tuneUpPath) {
      throw new AssertionException("output, refImages, tuneUp pathes can't be null");
    }

    this.tuneUpPath     = tuneUpPath;
    this.outputPath     = outputPath;
    this.refImagesPath  = refImagesPath;

    var target          = UIATarget.localTarget();
    if (!target) {
      throw new AssertionException("unable to get localTarget");
    }

    this.host           = target.host();
    if (!this.host) {
      throw new AssertionException("unable to get current UAIHost");
    }
  }

  CanvasImageAsserter.prototype.assertImageNamed = function(imageName, threshold) {
    var command,
        taskResult,
        assertSuccessfull = false,
        SUCCESS_EXIT_CODE = 0,
        TIMEOUT           = 5,
        args              = [this.outputPath, this.refImagesPath, imageName, threshold];

    command     = this.tuneUpPath + '/image_asserter';
    taskResult  = this.host.performTaskWithPathArgumentsTimeout(command,
                                                                args,
                                                                TIMEOUT);

    assertSuccessful = (taskResult.exitCode === SUCCESS_EXIT_CODE);
    if (!assertSuccessful) {
      UIALogger.logError(taskResult.stderr);
    }

    return assertSuccessful;
  };

  return CanvasImageAsserter;
}());

function createCanvasImageAsserter(tuneUpPath, outputPath, refImagesPath) {
  this.imageAsserter = new ImageAsserter(tuneUpPath, outputPath, refImagesPath);
}

function assertCanvasScreenMatchesImageNamed(imageName, message, threshold) {
  if (!this.imageAsserter) {
    throw new AssertionException("imageAsserter isn't created.");
  }

  captureLocalizedScreenshot(imageName)
  UIATarget.localTarget().delay(60); // delay for screenshot to be saved

  assertCanvasScreenWithNameMatchesImageNamed(imageName, message, threshold)
}

function assertCanvasScreenWithNameMatchesImageNamed(imageName, message, threshold) {
  if (!this.imageAsserter) {
    throw new AssertionException("imageAsserter isn't created.");
  }

  var localizedName = localizedScreenshotName(imageName)
  var assertionPassed = this.imageAsserter.assertImageNamed(localizedName, threshold);
  if (!assertionPassed) {
    if (!message) message = 'Assertion of the image ' + localizedName + ' failed.';
    throw new AssertionException(message);
  }
}
