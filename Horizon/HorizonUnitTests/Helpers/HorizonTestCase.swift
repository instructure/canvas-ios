//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Horizon

class HorizonTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: NSManagedObjectContext {
        return database.viewContext
    }

    var api: API { environment.api }
    var environment: TestEnvironment!
    var queue = OperationQueue()
    var router = TestRouter()
    var logger = TestLogger()

    let window = UIWindow()

    override func setUp() {
        super.setUp()
        OfflineModeAssembly.mock(OfflineModeInteractorMock(mockIsFeatureFlagEnabled: false))
        Clock.reset()
        API.resetMocks()
        LoginSession.clearAll()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        environment = TestEnvironment()
        AppEnvironment.shared = environment
        environment.api = API()
        environment.database = singleSharedTestDatabase
        environment.globalDatabase = singleSharedTestDatabase
        environment.router = router
        environment.logger = logger
        environment.currentSession = LoginSession.make()
        environment.window = window
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        super.tearDown()
        LoginSession.clearAll()
        window.rootViewController = UIViewController()
    }
}
