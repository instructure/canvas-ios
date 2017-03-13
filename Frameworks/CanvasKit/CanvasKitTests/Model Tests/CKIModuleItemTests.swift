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

class CKIModuleItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let moduleItemDictionary = Helpers.loadJSONFixture("module_item") as NSDictionary
        let moduleItem = CKIModuleItem(fromJSONDictionary: moduleItemDictionary)
        
        XCTAssertEqual(moduleItem.id!, "768", "Module Item id was not parsed correctly")
        XCTAssertEqual(moduleItem.title!, "Square Roots: Irrational numbers or boxy vegetables?", "Module Item title was not parsed correctly")
        XCTAssertEqual(moduleItem.type!, "Assignment", "Module Item type was not parsed correctly")
        XCTAssertEqual(moduleItem.contentID!, "1337", "Module Item contentID was not parsed correctly")
        XCTAssertEqual(moduleItem.itemID!, "1337", "Module Item itemID was not parsed correctly")
        XCTAssertEqual(moduleItem.pageID!, "my-page-title", "Module Item pageID was not parsed correctly")
        
        var url = NSURL(string:"https://canvas.example.edu/courses/222/modules/items/768")
        XCTAssertEqual(moduleItem.htmlURL!, url!, "Module Item htmlURL was not parsed correctly")
        
        url = NSURL(string:"https://canvas.example.edu/api/v1/courses/222/assignments/1337")
        XCTAssertEqual(moduleItem.apiURL!, url!, "Module Item url was not parsed correctly")
        
        url = NSURL(string:"https://www.example.com/externalurl")
        XCTAssertEqual(moduleItem.externalURL!, url!, "Module Item externalURL was not parsed correctly")
        
        XCTAssertEqual(moduleItem.completionRequirement!, "min_score", "Module Item completionRequirement was not parsed correctly")
        XCTAssertEqual(moduleItem.minimumScore, 10, "Module Item minimumScore was not parsed correctly")
        XCTAssert(moduleItem.completed, "Module Item completed was not parsed correctly")
        XCTAssertEqual(moduleItem.pointsPossible, 20, "Module Item pointsPossible was not parsed correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        let date = formatter.dateFromString("2012-12-31T06:00:00-06:00")
        XCTAssertEqual(moduleItem.dueAt!, date, "Module Item dueAt date was not parsed correctly")
        XCTAssertEqual(moduleItem.unlockAt!, date, "Module Item unlockAt date was not parsed correctly")
        XCTAssertEqual(moduleItem.lockAt!, date, "Module Item lockAt date was not parsed correctly")
        
        XCTAssertEqual(moduleItem.path!, "/api/v1/items/768", "Module Item path was not parsed correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
