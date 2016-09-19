import XCTest
import SoGrey
import EarlGrey

class TeacherEarlGrey: LogoutBeforeEach {

  func testExample() {
    EarlGrey().selectElementWithMatcher(grey_accessibilityID("domain_search_field"))
      .assertWithMatcher(grey_notNil())
  }
}
