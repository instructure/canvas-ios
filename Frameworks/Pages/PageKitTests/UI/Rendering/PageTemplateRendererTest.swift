
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
