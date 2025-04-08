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
import SwiftUI

class CoreTestCase: XCTestCase {
    var database: NSPersistentContainer {
        return singleSharedTestDatabase
    }
    var databaseClient: NSManagedObjectContext {
        return database.viewContext
    }
    var api: API { environment.api }
    var router: TestRouter!
    var logger: TestLogger!
    var analytics = MockAnalyticsHandler()
    var remoteLogHandler = MockRemoteLogHandler()

    lazy var environment = TestEnvironment()
    lazy var envResolver = TestCourseSyncEnvironmentResolver(env: environment)
    var currentSession: LoginSession!
    var login = TestLoginDelegate()

    let notificationCenter = MockUserNotificationCenter()
    var pushNotificationsInteractor: PushNotificationsInteractor!

    lazy var uploadManager = MockUploadManager(env: environment)

    lazy var testFile: URL = {
        let bundle = Bundle(for: type(of: self))
        return bundle.url(forResource: "fileupload", withExtension: "txt")!
    }()
    /// This directory can be used to store temporary files. It's cleared after each test case.
    public let workingDirectory = URL.Directories.temporary.appendingPathComponent(
        "CoreTestCase",
        isDirectory: true
    )

    let window = UIWindow()

    override func setUpWithError() throws {
        try super.setUpWithError()
        try FileManager.default.createDirectory(
            at: workingDirectory,
            withIntermediateDirectories: true
        )
    }

    override func setUp() {
        super.setUp()
        OfflineModeAssembly.mock(OfflineModeInteractorMock(mockIsFeatureFlagEnabled: false))
        Clock.reset()
        API.resetMocks()
        LoginSession.clearAll()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        router = environment.router as? TestRouter
        logger = environment.logger as? TestLogger
        currentSession = environment.currentSession
        environment.loginDelegate = login
        AppEnvironment.shared = environment
        AppEnvironment.shared.uploadManager = uploadManager
        LoginSession.add(environment.currentSession!)
        envResolver.offlineDirectoryOverride = workingDirectory
        pushNotificationsInteractor = PushNotificationsInteractor(notificationCenter: notificationCenter, logger: logger)
        MockUploadManager.reset()
        UUID.reset()
        ExperimentalFeature.allEnabled = false
        Analytics.shared.handler = analytics
        RemoteLogger.shared.handler = remoteLogHandler
        environment.app = .student
        environment.window = window
        environment.k5.userDidLogout()
        resetBrandConfig()
        window.rootViewController = mainViewController
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        super.tearDown()
        LoginSession.clearAll()
        window.rootViewController = mainViewController
    }

    override func tearDownWithError() throws {
        do {
            try FileManager.default.removeItem(at: workingDirectory)
        } catch (let error) {
            let nsError = error as NSError

            // Swallow no such file or directory error, the folder is already removed.
            guard nsError.domain == NSCocoaErrorDomain, nsError.code == 4 else {
                throw error
            }
        }

        try super.tearDownWithError()
    }

    func waitForMainAsync() {
        let main = expectation(description: "main.async")
        DispatchQueue.main.async { main.fulfill() }
        wait(for: [main], timeout: 1)
    }

    @discardableResult
    func waitForView<V: UIView>(of type: V.Type = V.self, withAccessID accessID: String, in parent: UIView?) throws -> V {
        var count: Int = 0
        var view: V?

        repeat {
            waitForMainAsync()
            view = parent?.findSubview(of: type, accessID: accessID)
            count += 1
        } while view == nil && count < 100

        return try XCTUnwrap(view)
    }

    private func resetBrandConfig() {
        Brand.shared = Brand(
            buttonPrimaryBackground: nil,
            buttonPrimaryText: nil,
            buttonSecondaryBackground: nil,
            buttonSecondaryText: nil,
            fontColorDark: nil,
            headerImageBackground: nil,
            headerImage: nil,
            linkColor: nil,
            navBackground: nil,
            navBadgeBackground: nil,
            navBadgeText: nil,
            navIconFill: nil,
            navIconFillActive: nil,
            navTextColor: nil,
            navTextColorActive: nil,
            primary: nil
        )
    }
}

private let mainViewController = UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()

extension CoreTestCase {
    /// Do not use repeatedly in the same test method, because it could cause flaky `testTree`.
    public func hostSwiftUIController<V: View>(_ view: V, thoroughness: Int = 10) -> CoreHostingController<V> {
        let controller = CoreHostingController(view)
        window.rootViewController = controller
        var count = 0
        while controller.testTree == nil, count < thoroughness {
            count += 1
            let expectation = XCTestExpectation()
            DispatchQueue.main.async { expectation.fulfill() }
            wait(for: [ expectation ], timeout: 30)
        }
        return controller
    }
    public func hostSwiftUI<V: View>(_ view: V) -> V {
        return hostSwiftUIController(view).rootView.content
    }
}

extension UIView {

    func findSubview(accessID: String) -> UIView? {
        for subview in subviews {
            if subview.accessibilityIdentifier == accessID {
                return subview
            }
            if let found = subview.findSubview(accessID: accessID) {
                return found
            }
        }
        return nil
    }

    func findSubview<V: UIView>(of type: V.Type = V.self, accessID: String) -> V? {
        for subview in subviews {
            if let found = subview as? V, found.accessibilityIdentifier == accessID {
                return found
            }
            if let found = subview.findSubview(of: type, accessID: accessID) {
                return found
            }
        }
        return nil
    }
}
