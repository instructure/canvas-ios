import XCTest

// Logs out before each test.
class LogoutBeforeEach: XCTestCase {

  override func setUp() {
    super.setUp()

    let delegate = UIApplication.sharedApplication().delegate!
    delegate.performSelector(#selector(AppDelegate.resetApplicationForTesting))
  }
}
