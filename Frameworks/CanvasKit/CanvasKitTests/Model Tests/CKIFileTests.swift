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

class CKIFileTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let fileDictionary = Helpers.loadJSONFixture("file") as NSDictionary
        let file = CKIFile(fromJSONDictionary: fileDictionary)
        
        XCTAssertEqual(file.id!, "569", "File id was not parsed correctly")
        XCTAssertNotNil(file.lockInfo, "File lock info was not parsed correctly")
        XCTAssertEqual(file.size, 4, "File size was not parsed correctly")
        XCTAssertEqual(file.contentType!, "text/plain", "File content type was not parsed correctly")
        XCTAssertEqual(file.name!, "file.txt", "File name was not parsed correctly")
        XCTAssertEqual(file.url!, NSURL(string: "http://www.example.com/files/569/download?download_frd=1/u0026verifier=c6HdZmxOZa0Fiin2cbvZeI8I5ry7yqD7RChQzb6P")!, "File url was not parsed correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        
        let date = formatter.dateFromString("2012-07-06T14:58:50Z")
        XCTAssertEqual(file.createdAt!, date, "File created at date was not parsed correctly")
        XCTAssertEqual(file.updatedAt!, date, "File created at date was not parsed correctly")
        XCTAssertEqual(file.lockAt!, date, "File locked at date was not parsed correctly")
        XCTAssertEqual(file.unlockAt!, date, "File unlock at date was not parsed correctly")
        
        XCTAssert(file.hiddenForUser, "File is hidden for user not parsed correctly")
        XCTAssertEqual(file.thumbnailURL!, NSURL(string: "http://www.instructure.testing/this/url")!, "File thumbnail url not parsed correctly")
        XCTAssertEqual(file.path!, "/api/v1/files/569", "File path was not parsed correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
