//
//  TabTests.swift
//  Enrollments
//
//  Created by Egan Anderson on 6/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import CoreData
@testable import EnrollmentKit
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal

class TabTests: UnitTestCase {
    let session = Session.inMemory
    var context: NSManagedObjectContext!
    var tab: Tab!
    
    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
            tab = Tab.build(inSession: session)
        }
    }
    
    // MARK: updateValues
    
    func testTab_updateValues() {
        attempt {
            try tab.updateValues(tabJSON, inContext: context)
        }
        
        XCTAssertEqual("1", tab.id, "id should match")
        XCTAssertEqual(NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605"), tab.url, "url should match")
        XCTAssertEqual(Int32(1), tab.position, "position should match")
        XCTAssertEqual("1", tab.label, "label should match")
        XCTAssert(tab.isValid)
    }
    
    func testTab_updateValues_fullURL() {
        attempt {
            try tab.updateValues(fullURLJSON, inContext: context)
        }
        XCTAssertEqual(NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605"), tab.url, "url should match")
        XCTAssert(tab.isValid)
    }

    
    func testTab_updateValues_error() {
        var failed = false
        do {
            try tab.updateValues(badJSON, inContext: context)
        } catch {
            failed = true
        }
        
        XCTAssertTrue(failed)
    }
    
    
    // MARK: predicate
    
    func testTab_uniquePredicateForObject(){
        attempt{
            let predicate: NSPredicate = try Tab.uniquePredicateForObject(fullURLJSON)
            let context: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            XCTAssertEqual(String(format: "id == \"1\" AND rawContextID == \"%@\"", context.canvasContextID), predicate.predicateFormat, "predicate should match")
        }
    }
    
    
    // MARK: isPages, isHome, isPage
    
    func testTab_isPages() {
        attempt{
            try tab.updateValues(pagesJSON, inContext: context)
            XCTAssert(tab.isPages)
        }
    }
    
    func testTab_isHome() {
        attempt{
            try tab.updateValues(homeJSON, inContext: context)
            XCTAssert(tab.isHome)
        }
    }
    
    func testTab_isPage() {
        attempt{
            try tab.updateValues(pageJSON, inContext: context)
            XCTAssert(tab.isPage)
        }
    }
    
    
    // MARK: get contextID
    
    func testTab_contextID() {
        attempt{
            try tab.updateValues(tabJSON, inContext: context)
            let contextID: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            XCTAssertEqual(contextID, tab.contextID, "contextID should match")
        }
    }
    
    
    //MARK: JSON tabs
    
    private var tabJSON: JSONObject {
        return [
            "url": "https://mobiledev.instructure.com/api/v1/courses/1422605",
            "id": "1",
            "position": 1,
            "label": "1",
        ]
    }
    
    private var fullURLJSON: JSONObject {
        return [
            "full_url": "https://mobiledev.instructure.com/api/v1/courses/1422605",
            "id": "1",
            "position": 1,
            "label": "1",
        ]
    }
    
    private var badJSON: JSONObject {
        return [
            "url": "www.instructure.com",
            "id": "1",
            "position": 1,
            "label": "1",
        ]
    }
    
    private var pagesJSON: JSONObject {
        return [
            "url": "https://mobiledev.instructure.com/api/v1/courses/1422605",
            "id": "pages",
            "position": 1,
            "label": "1",
        ]
    }
    
    private var homeJSON: JSONObject {
        return [
            "url": "https://mobiledev.instructure.com/api/v1/courses/1422605",
            "id": "home",
            "position": 1,
            "label": "1",
        ]
    }
    
    private var pageJSON: JSONObject {
        return [
            "url": "https://mobiledev.instructure.com/api/v1/courses/1422605",
            "id": "wiki",
            "position": 1,
            "label": "1",
        ]
    }
}
