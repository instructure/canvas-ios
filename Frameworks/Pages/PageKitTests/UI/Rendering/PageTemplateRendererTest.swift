//
//  PageTemplateRendererTest.swift
//  Pages
//
//  Created by Joseph Davison on 6/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import PageKit
import SoAutomated
import DoNotShipThis
import TooLegit
import SoPersistent

class PageTemplateRendererTest: UnitTestCase {

    let session = Session.ivy

    func testRenderer_replacesTemplateFieldsWithTheCorrectValues() {
        attempt {
            let page = Page.build(try session.pagesManagedObjectContext())

            let html = PageTemplateRenderer.htmlStringForPage(page)

            XCTAssertFalse(html.containsString("{$TITLE$}"))
            XCTAssertFalse(html.containsString("{$PAGE_BODY$}"))
            XCTAssertFalse(html.containsString("{$CSS$}"))
            XCTAssertFalse(html.containsString("{$REWRITE_LINKS_JS$}"))
            XCTAssertFalse(html.containsString("{$JQUERY_LOCAL_JS$}"))
            XCTAssertFalse(html.containsString("{$IMAGES_LOADED_JS$}"))

            XCTAssert(html.containsString(page.title))
            if let body = page.body {
                XCTAssert(html.containsString(body))
            }
        }
    }

}
