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

class CKILockInfoTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let lockInfoDictionary = Helpers.loadJSONFixture("lock_info") as NSDictionary
        var error: NSError? = nil
        let lockInfo: CKILockInfo = MTLJSONAdapter.modelOfClass(CKILockInfo.self, fromJSONDictionary: lockInfoDictionary, error: &error) as CKILockInfo
        if error != nil {
            println("Error parsing model \(error)");
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2013-07-22T21:22:06Z")
        
        XCTAssertEqual(lockInfo.unlockAt!, date, "LockInfo unlockAt did not parse correctly")
        XCTAssertEqual(lockInfo.startAt!, date, "LockInfo startAt did not parse correctly")
        XCTAssertEqual(lockInfo.endAt!, date, "LockInfo endAt did not parse correctly")
        XCTAssertEqual(lockInfo.assetString!, "wiki_page_1664923", "LockInfo assetString did not parse correctly")
        XCTAssertEqual(lockInfo.moduleID!, "843260", "LockInfo moduleID did not parse correctly")
        XCTAssertEqual(lockInfo.moduleName!, "Unit 4", "LockInfo moduleName did not parse correctly")
        XCTAssertEqual(lockInfo.moduleCourseID!, "710747", "LockInfo moduleCourseID did not parse correctly")
        
    }
}
