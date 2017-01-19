//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import XCTest
@testable import SoLazy

class SoLazyTests: XCTestCase {
    
    let notificationHandler = LocalNotificationHandler.sharedInstance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocalNotification() {
        XCTAssertNotNil(notificationHandler, "it exists!")
    }
    
    func testLocalNotificationDueDateStringFormatting() {
        XCTAssert(notificationHandler.dueDateFromMinuteOffset(1) == "1 minute")
        XCTAssert(notificationHandler.dueDateFromMinuteOffset(5) == "5 minutes")
        XCTAssert(notificationHandler.dueDateFromMinuteOffset(LocalNotificationConstants.LocalNotificationNumberMinutesInHour) == "1 hour")
        XCTAssert(notificationHandler.dueDateFromMinuteOffset(LocalNotificationConstants.LocalNotificationNumberMinutesInHour * 5) == "5 hours")
        XCTAssert(notificationHandler.dueDateFromMinuteOffset(LocalNotificationConstants.LocalNotificationNumberMinutesInDay) == "1 day")
        XCTAssert(notificationHandler.dueDateFromMinuteOffset(LocalNotificationConstants.LocalNotificationNumberMinutesInDay * 5) == "5 days")
    }
    
    func testLocalNotificationUserInfoDictionary() {
        let fakeAssignment = NotifiableObject(due: Date(timeIntervalSinceNow: 10.0), name: "School of Hard Knock 1", url: URL(string: "https://mobiledev.instructure.com/courses/1140383/assignments/4799961")!, id: "4799961")
        let userInfo = notificationHandler.userInfoDictionary(fakeAssignment)
        
        XCTAssertNotNil(userInfo, "failed to create userInfo object from assignment mock object")
        XCTAssert(userInfo[LocalNotificationConstants.LocalNotificationAssignmentIDKey]! as String == fakeAssignment.id)
        XCTAssert(userInfo[LocalNotificationConstants.LocalNotificationAssignmentURLKey]! as String == fakeAssignment.url.description)
    }

    func testUnitTesting() {
        XCTAssert(unitTesting)
    }
}
