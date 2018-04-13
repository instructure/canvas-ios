import XCTest
import SoGrey
import EarlGrey
import CanvasCore
import SoSeedySwift
@testable import CanvasKeymaster

class LoginTests: StudentUITestBase {
    
    func testLoginPageExists() {
        e.selectBy(id: "findMySchoolButton").assertExists()
    }
    
    func testLoginSearchPage() {
        e.selectBy(id: "findMySchoolButton").assertExists()
        e.selectBy(id: "findMySchoolButton").tap()
        e.selectBy(id: "searchSchoolTextField").assertExists()
    }
}
