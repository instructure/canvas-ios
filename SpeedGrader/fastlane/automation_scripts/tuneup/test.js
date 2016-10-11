/**
 * Run a new test with the given +title+ and function body, which will
 * be executed within the proper test declarations for the UIAutomation
 * framework. The given function will be handed a +UIATarget+ and
 * a +UIApplication+ object which it can use to exercise and validate your
 * application.
 *
 * The +options+ parameter is an optional object/hash thingie that
 * supports the following:
 *    logTree -- a boolean to log the element tree when the test fails (default 'true')
 *
 * Example:
 * test("Sign-In", function(target, application) {
 *   // exercise and validate your application.
 * });
 *
 * The +title+ is checked against every element of a global TUNEUP_ONLY_RUN
 * array. To check, each element is converted to a RegExp. The test is only
 * executed, if one check succeeds. If TUNEUP_ONLY_RUN is not defined,
 * no checks are performed.
 */
function test(title, f, options) {
  if (typeof TUNEUP_ONLY_RUN !== 'undefined') {
    for (var i = 0; i < TUNEUP_ONLY_RUN.length; i++) {
        if (new RegExp("^" + TUNEUP_ONLY_RUN[i] + "$").test(title)) {
          break;
        }
        if (i == TUNEUP_ONLY_RUN.length -1) {
          return;
        }
    }
  }

  if (!options) {
    options = testCreateDefaultOptions();
  }
  target = UIATarget.localTarget();
  application = target.frontMostApp();
  UIALogger.logStart(title);
  try {
    f(target, application);
    UIALogger.logPass(title);
  }
  catch (e) {
    UIALogger.logError(e.toString());
    if (options.logStackTrace) UIALogger.logError(e.stack);
    if (options.logTree) target.logElementTree();
    if (options.logTreeJSON) application.mainWindow().logElementTreeJSON();
    if (options.screenCapture) target.captureScreenWithName(title + '-fail');
    UIALogger.logFail(title);
  }
}

/**
 * Helper function to isolate clients from additional option changes. Clients can use this function to get a new option object and then only change the options they care about, confident that any new options added since their
 * code was created will contain the new default values.
 * @returns {Object} containing the error options
 */
function testCreateDefaultOptions() {
  return {
    logStackTrace: false,
    logTree: true,
    logTreeJSON: false,
    screenCapture: true
  };
}

