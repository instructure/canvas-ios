//
// Copyright (C) 2018-present Instructure, Inc.
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
import Core
import TestsFoundation
import CoreData
@testable import Student

class PersistenceTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: PersistenceClient {
        return database.mainClient
    }

    var api = MockAPI()
    var queue = OperationQueue()
    var router = TestRouter()
    var env = testEnvironment()
    var logger = TestLogger()

    override func setUp() {
        super.setUp()
        queue = OperationQueue()
        router = TestRouter()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        env = testEnvironment()
        env.api = api
        env.database = database
        env.globalDatabase = database
        env.router = router
        env.logger = logger
    }
}
