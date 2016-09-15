//
//  Page+NetworkTests.swift
//  Pages
//
//  Created by Joseph Davison on 5/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import PageKit
import XCTest
import SoAutomated
import SoPersistent
import TooLegit
import DoNotShipThis
import Marshal
import Result

class PageNetworkTests: XCTestCase {
    
    func testGetPages_returnsPagesWithTheRequiredFields() {
        guard let pages = getPages(), page = pages.first else {
            XCTFail("expected page")
            return
        }
        
        XCTAssert(page.keys.contains("url"))
        XCTAssert(page.keys.contains("title"))
        XCTAssert(page.keys.contains("created_at"))
        XCTAssert(page.keys.contains("editing_roles"))
        XCTAssert(page.keys.contains("published"))
        XCTAssert(page.keys.contains("front_page"))
        XCTAssert(page.keys.contains("locked_for_user"))
    }

    func testGetPages_returnsTheCorrectNumberOfPages() {
        let pages = getPages()

        XCTAssertEqual(pages?.count, 17)
    }

    func testGetPage_returnsPageWithTheRequiredFields() {
        let session = Session.ivy
        var response: JSONObject?

        attempt {
            stub(session, "page") { expectation in
                try Page.getPage(session, contextID: ContextID(id: "24219", context: .Course), url: "test-page").startWithCompletedExpectation(expectation) { value in response = value }
            }
        }

        guard let page = response else {
            XCTFail("expected page")
            return
        }

        XCTAssert(page.keys.contains("url"))
        XCTAssert(page.keys.contains("title"))
        XCTAssert(page.keys.contains("created_at"))
        XCTAssert(page.keys.contains("editing_roles"))
        XCTAssert(page.keys.contains("published"))
        XCTAssert(page.keys.contains("front_page"))
        XCTAssert(page.keys.contains("locked_for_user"))
    }

    func testGetFrontPage_returnsPageWithTheRequiredFields() {
        let session = Session.ivy
        var response: JSONObject?

        attempt {
            stub(session, "front-page") { expectation in
                try Page.getFrontPage(session, contextID: ContextID(id: "24219", context: .Course)).startWithCompletedExpectation(expectation) { value in response = value }
            }
        }

        guard let page = response else {
            XCTFail("expected page")
            return
        }

        XCTAssert(page.keys.contains("url"))
        XCTAssert(page.keys.contains("title"))
        XCTAssert(page.keys.contains("created_at"))
        XCTAssert(page.keys.contains("editing_roles"))
        XCTAssert(page.keys.contains("published"))
        XCTAssert(page.keys.contains("front_page"))
        XCTAssert(page.keys.contains("locked_for_user"))
    }

    func getPages() -> [JSONObject]? {
        let session = Session.ivy
        var response: [JSONObject]?

        attempt {
            stub(session, "pages-list") { expectation in
                try Page.getPages(session, contextID: ContextID(id: "24219", context: .Course)).startWithCompletedExpectation(expectation) { value in response = value }
            }
        }

        return response
    }

}

extension String: Fixture {
    public var name: String { return self }
    public var bundle: NSBundle { return NSBundle(forClass: PageNetworkTests.self) }
}