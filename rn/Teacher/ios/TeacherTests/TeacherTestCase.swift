//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
import Core
import TestsFoundation
import CoreData

class TeacherTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: PersistenceClient {
        return database.mainClient
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
    }
}
