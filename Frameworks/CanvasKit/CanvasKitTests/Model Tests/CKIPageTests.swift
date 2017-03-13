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

class CKIPageTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let pageDictionary = Helpers.loadJSONFixture("page") as NSDictionary
        let page = CKIPage(fromJSONDictionary: pageDictionary)
        
        XCTAssertEqual(page.title!, "My Page Title", "Page title did not parse correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2012-08-06T16:46:33-06:00")
        XCTAssertEqual(page.createdAt!, date, "Page createdAt did not parse correctly")
        
        date = formatter.dateFromString("2012-08-08T14:25:20-06:00")
        XCTAssertEqual(page.updatedAt!, date, "Page updatedAt did not parse correctly")
        XCTAssert(page.hideFromStudents, "Page hideFromStudents did not parse correctly")
        XCTAssertNotNil(page.lastEditedBy, "Page lastEditedBy did not parse correctly")
        XCTAssert(page.published, "Page published did not parse correctly")
        XCTAssert(page.frontPage, "Page frontPage did not parse correctly")
        XCTAssertEqual(page.path!, "/api/v1/pages/my-page-title", "Page path did not parse correctly")
    }
}
