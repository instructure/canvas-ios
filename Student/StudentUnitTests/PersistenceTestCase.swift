//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core
import TestsFoundation
import CoreData
@testable import Student

class PersistenceTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: NSManagedObjectContext {
        return database.viewContext
    }

    var api = MockURLSession.self
    var queue = OperationQueue()
    var router = TestRouter()
    var env = TestEnvironment()
    var logger = TestLogger()
    var uploadManager = MockUploadManager()
    var currentSession = LoginSession.make()

    override func setUp() {
        super.setUp()
        MockURLSession.reset()
        LoginSession.useTestKeychain()
        queue = OperationQueue()
        router = TestRouter()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        env = TestEnvironment()
        env.api = URLSessionAPI()
        env.database = database
        env.globalDatabase = database
        env.router = router
        env.logger = logger
        env.currentSession = currentSession
        AppEnvironment.shared.api = env.api
        AppEnvironment.shared.database = env.database
        AppEnvironment.shared.globalDatabase = env.globalDatabase
        AppEnvironment.shared.router = env.router
        AppEnvironment.shared.logger = env.logger
        AppEnvironment.shared.currentSession = env.currentSession
        UploadManager.shared = uploadManager
        MockUploadManager.reset()
    }

    override func tearDown() {
        super.tearDown()
        LoginSession.clearAll()
    }
}
