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
        URLSessionAPI.delegateURLSession = { _, _ in MockURLSession() }
        UploadManager.shared = MockUploadManager()
        try! NSPersistentContainer.shared.clearAllRecords()
    }

    func waitForMainAsync() {
        let main = expectation(description: "main.async")
        DispatchQueue.main.async { main.fulfill() }
        wait(for: [main], timeout: 1)
    }
}
