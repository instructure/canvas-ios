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

class CKITabTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testJSONModelConversion() {
        //See the comments in CKISubmissionSet. I don't think we currently have json to test this code
        let tabDictionary = Helpers.loadJSONFixture("tab") as NSDictionary
        let tab = CKITab(fromJSONDictionary: tabDictionary)
        
        var url = NSURL(string:"/courses/1/external_tools/4")
        XCTAssertEqual(tab.htmlURL!, url!, "Tab url was not parsed correctly")
        XCTAssertEqual(tab.label!, "WordPress", "Tab label was not parsed correctly")
        XCTAssertEqual(tab.type!, "external", "Tab external was not parsed correctly")
        
        url = NSURL(string:"https://canvas.instructure.com/courses/1/external_tools/4")
        XCTAssertEqual(tab.url!, url!, "Tab url was not parsed correctly")
        
        XCTAssertEqual(tab.path!, "/api/v1/context_external_tool_4", "Tab path was not parsed correctly")
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
