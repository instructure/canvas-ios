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
        return singleSharedTestDatabase
    }
    var databaseClient: NSManagedObjectContext {
        return database.viewContext
    }
    var api = MockURLSession.self
    var router: TestRouter!
    var logger: TestLogger!
    var analytics = TestAnalyticsHandler()

    var environment = TestEnvironment()
    var currentSession: LoginSession!
    var login = TestLoginDelegate()

    let notificationCenter = MockUserNotificationCenter()
    var notificationManager: NotificationManager!

    lazy var testFile: URL = {
        let bundle = Bundle(for: type(of: self))
        return bundle.url(forResource: "fileupload", withExtension: "txt")!
    }()

    let window = UIWindow()

    override func setUp() {
        super.setUp()
        MockURLSession.reset()
        LoginSession.useTestKeychain()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        environment = TestEnvironment()
        router = environment.router as? TestRouter
        logger = environment.logger as? TestLogger
        currentSession = environment.currentSession
        environment.loginDelegate = login
        AppEnvironment.shared = environment
        LoginSession.add(environment.currentSession!)
        notificationManager = NotificationManager(notificationCenter: notificationCenter, logger: logger)
        UploadManager.shared = MockUploadManager()
        MockUploadManager.reset()
        UUID.reset()
        ExperimentalFeature.allEnabled = false
        Analytics.shared.handler = analytics
        environment.app = .student
        environment.window = window
        window.rootViewController = UIViewController()
    }

    override func tearDown() {
        super.tearDown()
        LoginSession.clearAll()
    }

    func waitForMainAsync() {
        let main = expectation(description: "main.async")
        DispatchQueue.main.async { main.fulfill() }
        wait(for: [main], timeout: 1)
    }
}

class TestAnalyticsHandler: AnalyticsHandler {
    struct Event {
        let name: String
        let parameters: [String: Any]?
    }
    var events = [Event]()

    func handleEvent(_ name: String, parameters: [String: Any]?) {
        events.append(.init(name: name, parameters: parameters))
    }
}
