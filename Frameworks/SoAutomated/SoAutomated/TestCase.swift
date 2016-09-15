import XCTest
import Foundation

public class TestCase: XCTestCase {
    public override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        if #available(iOS 9.0, *) {
            let app = XCUIApplication()

            // args intended to indicate to app to logout the previous session, if one exists
            app.launchArguments = [ "START_NEW_SESSION" ]
            app.launch()
        }

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        if #available(iOS 9.0, *) {
            XCUIDevice.sharedDevice().orientation = .Portrait
        }
    }

    public override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        if #available(iOS 9.0, *) {
            app.terminate()
        }
    }
}
