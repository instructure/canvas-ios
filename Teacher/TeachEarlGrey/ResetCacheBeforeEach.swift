import XCTest

// Resets the cache before each test. Remains logged in.
class ResetCacheBeforeEach: XCTestCase {

  override func setUp() {
    super.setUp()

    let delegate = UIApplication.sharedApplication().delegate!
    delegate.performSelector(#selector(AppDelegate.resetCacheForTesting))
  }
}
