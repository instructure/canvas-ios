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
@testable import CanvasCore

class StudentTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return singleSharedTestDatabase
    }
    var databaseClient: NSManagedObjectContext {
        return database.viewContext
    }

    var api: API { env.api }
    var queue = OperationQueue()
    var env: TestEnvironment!
    var logger: TestLogger!
    var router: TestRouter { env.router as! TestRouter }
    var uploadManager = MockUploadManager()
    var currentSession: LoginSession!

    override func setUp() {
        super.setUp()
        API.resetMocks()
        LoginSession.clearAll()
        queue = OperationQueue()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        env = TestEnvironment()
        logger = env.logger as? TestLogger
        currentSession = env.currentSession
        AppEnvironment.shared = env
        UploadManager.shared = uploadManager
        MockUploadManager.reset()
    }

    override func tearDown() {
        super.tearDown()
        LoginSession.clearAll()
    }
}
