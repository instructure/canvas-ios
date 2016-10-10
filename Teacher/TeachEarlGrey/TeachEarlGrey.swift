import XCTest
import SoGrey
import EarlGrey

class TeacherEarlGrey: LogoutBeforeEach {

  func testExample() {
// When we switched from CanvasKeymaster (ObjC) to Keymaster (Swift) I think this test broke.
// The Keymaster domain search field does not provide a11y ids. :shame:
    EarlGrey().selectElementWithMatcher(grey_accessibilityID("domain_search_field"))
      .assertWithMatcher(grey_notNil())
  }
}
