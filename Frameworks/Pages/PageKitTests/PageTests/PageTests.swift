//
//  PageTests.swift
//  Pages
//
//  Created by Joseph Davison on 5/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
@testable import PageKit
import SoAutomated
import CoreData
import Marshal
import SoPersistent
import TooLegit
import DoNotShipThis

class PageTests: XCTestCase {
    
    var page: Page!
    var context: NSManagedObjectContext!
    var contextID: ContextID!
    var session: Session!
    
    override func setUp() {
        super.setUp()
        session = Session.inMemory
        context = try! session.pagesManagedObjectContext()
        page = Page.build(context)
    }
    
    func testUpdateValues() {
        var json: JSONObject = [
            "locked_for_user" : false,
            "page_id" : 13624,
            "front_page" : false,
            "created_at" : "2011-01-10T15:26:38Z",
            "last_edited_by" : [
                "id" : 5356213,
                "display_name" : "Ivy Iversen",
                "avatar_image_url" : "https://mobiledev.instructure.com/images/thumbnails/56640046/jdWmlUJ45fnORk7lKkc7Z44t4dgLmIIooFSHXneW",
                "html_url" : "https://mobiledev.instructure.com/courses/24219/users/5356213"
            ],
            "url" : "test-page",
            "published" : true,
            "title" : "Test Page",
            "hide_from_students" : false,
            "html_url" : "https://mobiledev.instructure.com/courses/24219/pages/test-page"
        ]
        
        attempt {
            let context = try session.pagesManagedObjectContext()
            try page.updateValues(json, inContext: context)
            
            XCTAssertEqual(page.title, "Test Page")
            XCTAssertEqual(page.url, "test-page")
            XCTAssertTrue(NSDate(year: 2011, month: 01, day: 10).isTheSameDayAsDate(page.createdAt))
            XCTAssertTrue(page.published)
            XCTAssertFalse(page.frontPage)
            XCTAssertEqual(page.contextID.canvasContextID, "course_24601")
            XCTAssertFalse(page.lockedForUser)
            XCTAssertEqual(page.lastEditedByName, "Ivy Iversen")
            XCTAssertEqual(page.lastEditedByAvatarUrl?.absoluteString, "https://mobiledev.instructure.com/images/thumbnails/56640046/jdWmlUJ45fnORk7lKkc7Z44t4dgLmIIooFSHXneW")

            // Test defaults for missing required values

            XCTAssertEqual(page.editingRoles, "", "should default to empty string when value not found")
            XCTAssertTrue(page.updatedAt.isEqualToDate(page.createdAt), "should default to creation date when last updated not found")
            
            XCTAssertNil(page.body)
            XCTAssertNil(page.lockExplanation)

            // Test explicit values for required fields with defaults

            json["editing_roles"] = "teachers"
            json["updated_at"] = "2016-05-25T21:06:11Z"
            
            try page.updateValues(json, inContext: context)
            
            XCTAssertTrue(NSDate(year: 2016, month: 05, day: 25).isTheSameDayAsDate(page.updatedAt))
            XCTAssertEqual(page.editingRoles, "teachers")
        }
    }
    
}