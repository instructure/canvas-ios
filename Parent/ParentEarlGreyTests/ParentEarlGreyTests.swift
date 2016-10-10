import XCTest
import EarlGrey
import SoGrey

class ParentEarlGreyTests: LogoutBeforeEach {
  func testEarlGrey() {
    EarlGrey().selectElementWithMatcher(grey_accessibilityID("email_field"))
      .assertWithMatcher(grey_notNil())
  }

    func testSomethingElse() {
        XCTAssert(true)
    }
}
