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
import SoPersistent
import SoAutomated

class LockableModelTests: XCTestCase {
    func testUpdateLockStatus() {
        attempt {
            let lockable = MyLockable(lockedForUser: false, lockExplanation: nil, canView: true)
            let json = ["locked_for_user": true, "lock_explanation": "Something here", "lock_info" : ["can_view": false]]
            try lockable.updateLockStatus(json)
            XCTAssert(lockable.lockedForUser, "it updates lockedForUser")
            XCTAssertFalse(lockable.canView, "it updates canView")
            XCTAssertEqual("Something here", lockable.lockExplanation, "it updates lockExplanation")

        }
    }

    func testUpdateLockStatusDefaults() {
        attempt {
            let lockable = MyLockable(lockedForUser: true, lockExplanation: nil, canView: false)
            let json: [String: AnyObject] = [:]
            try lockable.updateLockStatus(json)
            XCTAssertFalse(lockable.lockedForUser, "it defaults lockedForUser to false")
            XCTAssert(lockable.canView, "it defaults canView to true")
            XCTAssertNil(lockable.lockExplanation, "it default lockExplanation to nil")
        }
    }
}

// MARK: - Utils

class MyLockable: LockableModel {
    var lockedForUser: Bool
    var lockExplanation: String?
    var canView: Bool
    
    init(lockedForUser: Bool, lockExplanation: String?, canView: Bool) {
        self.lockedForUser = lockedForUser
        self.lockExplanation = lockExplanation
        self.canView = canView
    }
}
