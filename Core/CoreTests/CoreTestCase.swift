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

import Foundation
import XCTest
@testable import Core
import TestsFoundation
import CoreData

class CoreTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: NSManagedObjectContext {
        return database.viewContext
    }
    var api = MockAPI()
    var router = TestRouter()
    var logger = TestLogger()
    var environment: AppEnvironment!
    var currentSession = KeychainEntry.make()

    let notificationCenter = MockUserNotificationCenter()
    var notificationManager: NotificationManager!

    lazy var testFile: URL = {
        let bundle = Bundle(for: type(of: self))
        return bundle.url(forResource: "fileupload", withExtension: "txt")!
    }()

    override func setUp() {
        super.setUp()
        api = MockAPI()
        router = TestRouter()
        logger = TestLogger()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        environment = AppEnvironment.shared
        environment.api = api
        environment.globalDatabase = database
        environment.database = database
        environment.router = router
        environment.logger = logger
        environment.currentSession = currentSession
        notificationManager = NotificationManager(notificationCenter: notificationCenter, logger: logger)
        URLSessionAPI.delegateURLSession = { _, _, _ in MockURLSession() }
        UploadManager.shared = MockUploadManager()
        MockUploadManager.reset()
        UUID.reset()
    }

    func waitForMainAsync() {
        let main = expectation(description: "main.async")
        DispatchQueue.main.async { main.fulfill() }
        wait(for: [main], timeout: 1)
    }
}
