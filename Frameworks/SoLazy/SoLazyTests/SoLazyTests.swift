//
//  SoLazyTests.swift
//  SoLazyTests
//
//  Created by Derrick Hathaway on 10/5/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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
        let fakeAssignment = NotifiableObject(due: NSDate(timeIntervalSinceNow: 10.0), name: "School of Hard Knock 1", url: NSURL(string: "https://mobiledev.instructure.com/courses/1140383/assignments/4799961")!, id: "4799961")
        let userInfo = notificationHandler.userInfoDictionary(fakeAssignment)
        
        XCTAssertNotNil(userInfo, "failed to create userInfo object from assignment mock object")
        XCTAssert(userInfo[LocalNotificationConstants.LocalNotificationAssignmentIDKey]! as String == fakeAssignment.id)
        XCTAssert(userInfo[LocalNotificationConstants.LocalNotificationAssignmentURLKey]! as String == fakeAssignment.url.description)
    }

    func testUnitTesting() {
        XCTAssert(unitTesting)
    }
}
