//
// Copyright (C) 2019-present Instructure, Inc.
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

import Core
import TestsFoundation
import XCTest
import CoreData

class SubmitAssignmentTests: XCTestCase {
    let env = AppEnvironment.shared
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    let uploadManager = MockUploadManager()

    override func setUp() {
        super.setUp()

        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        MockURLSession.reset()
        UploadManager.shared = uploadManager
        env.database = database
        env.api = URLSessionAPI(accessToken: nil, actAsUserID: nil, baseURL: nil, urlSession: MockURLSession())
    }
}
