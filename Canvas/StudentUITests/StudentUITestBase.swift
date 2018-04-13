import Foundation
import XCTest
import SoGrey
import EarlGrey
import CanvasCore
import SoSeedySwift
import BuddyBuildSDK
@testable import CanvasKeymaster

class StudentUITestBase: CanvasUITest {
    override func setUp() {
        super.setUp()
        BuddyBuildSDK.startUITests()
        CanvasKeymaster.the().resetKeymasterForTesting()
        NativeLoginManager.shared().injectLoginInformation(nil)
        GREYTestHelper.enableFastAnimation()
        elementTimeout = 20 // Student app is slow :(
    }
    
    override func tearDown() {
        BuddyBuildSDK.stopUITests()
        super.tearDown()
    }
}
