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

class CoreTestCase: XCTestCase {
    var database: Persistence {
        return TestsFoundation.singleSharedTestDatabase
    }
    var databaseClient: PersistenceClient {
        return database.mainClient
    }
    var api = MockAPI()
    var backgroundAPI: MockAPI {
        return environment.backgroundAPI as! MockAPI
    }
    var queue = OperationQueue()
    var router = TestRouter()
    var logger = TestLogger()
    var environment: AppEnvironment!

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
        environment.backgroundAPIManager = MockBackgroundURLSessionManager(database: database)
        environment.globalDatabase = database
        environment.database = database
        queue = environment.queue
        environment.queue.maxConcurrentOperationCount = 1
        environment.router = router
        environment.logger = logger
        notificationManager = NotificationManager(notificationCenter: notificationCenter, logger: logger)
    }

    func addOperationAndWait(_ operation: Operation) {
        queue.addOperations([operation], waitUntilFinished: true)
    }
}
