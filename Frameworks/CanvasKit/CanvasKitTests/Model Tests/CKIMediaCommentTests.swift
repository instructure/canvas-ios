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

class CKIMediaCommentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let mediaCommentDictionary = Helpers.loadJSONFixture("media_comment") as NSDictionary
        let mediaComment = CKIMediaComment(fromJSONDictionary: mediaCommentDictionary)
        
        XCTAssertEqual(mediaComment.id!, "0_1175s92f", "CKIMediaComment id did not parse correctly")
        XCTAssertEqual(mediaComment.mediaID!, "0_1175s92f", "CKIMediaComment mediaID did not parse correctly")
        XCTAssertNil(mediaComment.displayName, "CKIMediaComment displayName did not parse correctly")
        XCTAssertEqual(mediaComment.contentType!, "video/mp4", "CKIMediaComment contentType did not parse correctly")
        XCTAssertEqual(mediaComment.mediaType!, "video", "CKIMediaComment mediaType did not parse correctly")

        let url = NSURL(string:"https://mobiledev.instructure.com/users/4301217/media_download?entryId=0_1175s92f&redirect=1&type=mp4")
        XCTAssertEqual(mediaComment.url!, url!, "CKIMediaComment url did not parse correctly")
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.t
        }
    }

}
