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

import XCTest
import Core
import TestsFoundation
import CoreData

class TeacherTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: NSManagedObjectContext {
        return database.viewContext
    }

    var api = MockAPI()
    var environment = AppEnvironment.shared
    var queue = OperationQueue()
    var router = TestRouter()
    var logger = TestLogger()

    override func setUp() {
        super.setUp()

        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        environment.api = api
        environment.database = singleSharedTestDatabase
        environment.globalDatabase = singleSharedTestDatabase
        environment.router = router
        environment.logger = logger
        environment.currentSession = KeychainEntry.make()
    }
}
