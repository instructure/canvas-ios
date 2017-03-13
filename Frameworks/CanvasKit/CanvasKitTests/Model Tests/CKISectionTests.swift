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

import XCTest

class CKISectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let sectionDictionary = Helpers.loadJSONFixture("section") as NSDictionary
        let section = CKISection(fromJSONDictionary: sectionDictionary)

        XCTAssertEqual(section.id!, "1", "section id not parsed correctly")
        XCTAssertEqual(section.name!, "Section A", "section name not parsed correctly")
        XCTAssertEqual(section.courseID!, "7", "section courseID not parsed correctly")
        XCTAssertEqual(section.path!, "/api/v1/sections/1", "section path not parsed correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
