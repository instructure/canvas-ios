import XCTest
import SoGrey
import EarlGrey
import CanvasCore
import SoSeedySwift
@testable import CanvasKeymaster

class StudentUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        CanvasKeymaster.the().resetKeymasterForTesting()
        NativeLoginManager.shared().injectLoginInformation(nil)
        GREYTestHelper.enableFastAnimation()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLoginPageExists() {
        e.selectBy(id: "findMySchoolButton").assertExists()
    }
    
    func testLoginSearchPage() {
        e.selectBy(id: "findMySchoolButton").assertExists()
        e.selectBy(id: "findMySchoolButton").tap()
        e.selectBy(id: "searchSchoolTextField").assertExists()
    }

    func testDataSeeding() {
        let course = SoSeedySwift.createCourse()
        let teacher = SoSeedySwift.createTeacher(in: course)
        SoSeedySwift.favorite(course, as: teacher)
        let loginInfo = SoSeedySwift.getNativeLoginInfo(teacher)
        NativeLoginManager.shared().injectLoginInformation(loginInfo)
        DashboardPage.sharedInstance.assertCourseExists(course)
    }
}
