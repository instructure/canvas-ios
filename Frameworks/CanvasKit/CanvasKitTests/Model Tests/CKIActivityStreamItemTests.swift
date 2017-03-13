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

class CKIActivityStreamItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamItemDictionary = Helpers.loadJSONFixture("activity_stream_item") as NSDictionary
        let streamItem = CKIActivityStreamMessageItem(fromJSONDictionary: activityStreamItemDictionary)
        
        var formatter = ISO8601DateFormatter()
        formatter.includeTime = true
    
        XCTAssertEqual(streamItem.id!, "1234", "Activity Stream Item id was not parsed correctly")
        
        XCTAssertEqual(streamItem.title!, "Stream Item Subject", "Activity Stream Item title was not parsed correctly")
        
        XCTAssertEqual(streamItem.message!, "This is the body text of the activity stream item. It is plain-text, and can be multiple paragraphs.", "Activity Stream Item message was not parsed correctly")

        XCTAssertEqual(streamItem.courseID!, "1", "Activity Stream Item courseID was not parsed correctly")
        
        XCTAssertEqual(streamItem.groupID!, "1", "Activity Stream Item groupID was not parsed correctly")
        
        var date = formatter.dateFromString("2011-07-13T09:12:00Z")
        XCTAssertEqual(streamItem.createdAt!, date, "Activity Stream Item createdAt date was not parsed correctly")
        
        date = formatter.dateFromString("2011-07-25T08:52:41Z")
        XCTAssertEqual(streamItem.updatedAt!, date, "Activity Stream Item updatedAt date was not parsed correctly")
        
        var url = NSURL(string:"http://canvas.instructure.com/api/v1/foo")
        XCTAssertEqual(streamItem.url!, url!, "Activity Stream Item url was not parsed correctly")

        url = NSURL(string:"http://canvas.instructure.com/api/v1/foo")
        XCTAssertEqual(streamItem.htmlURL!, url!, "Activity Stream Item htmlURL was not parsed correctly")
        
        XCTAssert(streamItem.isRead, "Activity Stream Item isRead was not parsed correctly")
        
       //Consider testing custom transformers at some point in time, which is probably never since we aren't doing it right now.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
