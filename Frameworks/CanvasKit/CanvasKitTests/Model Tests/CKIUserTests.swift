//
//  CKIUserTests.swift
//  CanvasKit
//
//  Created by Rick Roberts on 7/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIUserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSONModelConversion() {
        
        let userDictionary = Helpers.loadJSONFixture("user") as NSDictionary
        let user = CKIUser(fromJSONDictionary: userDictionary)
                
        XCTAssertEqual(user.id!, "1", "User id was not parsed correctly")
        XCTAssertEqual(user.name!, "Sheldon Cooper", "User name was not parsed correctly")
        XCTAssertEqual(user.sortableName!, "Cooper, Sheldon", "User sortable name was not parsed correctly")
        XCTAssertEqual(user.shortName!, "Shelly", "User short short anme was not parsed correctly")
        XCTAssertEqual(user.sisUserID!, "scooper", "User sis user id was not parsed correctly")
        XCTAssertEqual(user.loginID!, "sheldon@caltech.example.com", "user login id was not parsed correctly")
        XCTAssertEqual(user.email!, "sheldon@caltech.example.com", "user email was not parsed correctly")
        XCTAssertEqual(user.avatarURL!, NSURL(string: "http://instructure.com/sheldon.png")!, "user avatar url was not parsed correctly")
        XCTAssertEqual(user.locale!, "tlh", "user local was not parsed correctly")
        XCTAssertNil(user.calendar, "user calendar was not parsed correctly")
        
        var formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2012-05-30T17:45:25Z")
        
        XCTAssertEqual(user.lastLogin!, date, "user last login was not parsed correctly")
        XCTAssertEqual(user.timeZone!, "America/Denver", "user time zone was not parsed correctly")
        XCTAssertEqual(user.path!, "/api/v1/users/1", "User path was not parsed correctly")
    }
    
    func testJSONModelConversionPerformance() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
