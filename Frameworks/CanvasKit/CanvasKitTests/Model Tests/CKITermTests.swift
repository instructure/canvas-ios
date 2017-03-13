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

class CKITermTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let termDictionary = Helpers.loadJSONFixture("term") as NSDictionary
        let term = CKITerm(fromJSONDictionary: termDictionary)
        
        XCTAssertEqual(term.id!, "1", "term id was not parsed correctly")
        XCTAssertEqual(term.name!, "Spring 2014", "term name was not parsed correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2014-01-06T08:00:00-05:00")
        XCTAssertEqual(term.startAt!, date, "term startAt was not parsed correctly")
        
        date = formatter.dateFromString("2014-05-16T05:00:00-04:00")
        XCTAssertEqual(term.endAt!, date, "term endAt was not parsed correctly")
    }
}
