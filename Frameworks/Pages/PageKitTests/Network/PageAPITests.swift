//
//  PageAPITests.swift
//  Pages
//
//  Created by Joseph Davison on 5/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import TooLegit
import DoNotShipThis
import PageKit

class PageAPITests: XCTestCase {
    
    func testGetCoursePages() {
        let session = Session.art
        let request = try! PageAPI.getPages(session, contextID: ContextID(id: "24219", context: .Course))
        
        XCTAssertEqual("/api/v1/courses/24219/pages", request.URL?.relativePath, "it should have the correct path")
        XCTAssertEqual("per_page=99", request.URL?.query, "it should have the correct parameters")
    }
    
}
