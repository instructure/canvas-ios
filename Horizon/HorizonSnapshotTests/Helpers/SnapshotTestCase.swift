//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import SnapshotTesting
import SwiftUI
import TestsFoundation
import XCTest
@testable import Horizon
import CoreData
import HorizonUI

class HorizonSnapshotTestCase: XCTestCase {

    struct Device {
        let name: String
        let config: ViewImageConfig

        static let iPhone13 = Device(
            name: "iPhone13",
            config: .iPhone13
        )

        static let iPhoneSE = Device(
            name: "iPhoneSE",
            config: .iPhoneSe
        )

    }

    static let defaultDevices = [
        Device.iPhone13,
        Device.iPhoneSE
    ]

    static let allDevices = [
        Device.iPhone13,
        Device.iPhoneSE
    ]

    func snapshotDirectory(file: StaticString = #file) -> String? {
        let testFilePath = "\(file)"
        if let featureRange = testFilePath.range(of: "/Features/") {
            if let lastSlash = testFilePath.range(of: "/", options: .backwards, range: featureRange.upperBound..<testFilePath.endIndex) {
                let basePath = testFilePath[..<lastSlash.lowerBound]
                return "\(basePath)/__Snapshots__"
            }
        }
        return nil
    }

    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }

    func assertSnapshot<Content: View>(
        of view: Content,
        named name: String? = nil,
        devices: [Device] = HorizonSnapshotTestCase.defaultDevices,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        for device in devices {
            let snapshotName = name.map { "\($0)-\(device.name)" } ?? device.name

            let failure = verifySnapshot(
                of: view,
                as: .image(layout: .device(config: device.config)),
                named: snapshotName,
                record: nil,
                snapshotDirectory: snapshotDirectory(file: file),
                file: file,
                testName: testName,
                line: line
            )

            if let failureMessage = failure {
                XCTFail(failureMessage, file: file, line: line)
            }
        }
    }

    func assertSnapshot(
        of viewController: UIViewController,
        named name: String? = nil,
        devices: [Device] = HorizonSnapshotTestCase.defaultDevices,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        for device in devices {
            let snapshotName = name.map { "\($0)-\(device.name)" } ?? device.name

            let failure = verifySnapshot(
                of: viewController,
                as: .image(on: device.config),
                named: snapshotName,
                record: nil,
                snapshotDirectory: snapshotDirectory(file: file),
                file: file,
                testName: testName,
                line: line
            )

            if let failureMessage = failure {
                XCTFail(failureMessage, file: file, line: line)
            }
        }
    }

    func assertAccessibilitySnapshot<Content: View>(
        of view: Content,
        named name: String? = nil,
        sizes: [UIContentSizeCategory] = [.large, .extraExtraLarge, .accessibilityLarge],
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        for size in sizes {
            let sizeString = accessibilitySizeString(for: size)
            let snapshotName = name.map { "\($0)-\(sizeString)" } ?? sizeString

            var config = Device.iPhone13.config
            config.traits = UITraitCollection(preferredContentSizeCategory: size)

            let failure = verifySnapshot(
                of: view,
                as: .image(layout: .device(config: config)),
                named: snapshotName,
                record: nil,
                snapshotDirectory: snapshotDirectory(file: file),
                file: file,
                testName: testName,
                line: line
            )

            if let failureMessage = failure {
                XCTFail(failureMessage, file: file, line: line)
            }
        }
    }

    private func accessibilitySizeString(for category: UIContentSizeCategory) -> String {
        switch category {
        case .extraSmall: return "xSmall"
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "large"
        case .extraLarge: return "xLarge"
        case .extraExtraLarge: return "xxLarge"
        case .extraExtraExtraLarge: return "xxxLarge"
        case .accessibilityMedium: return "accMedium"
        case .accessibilityLarge: return "accLarge"
        case .accessibilityExtraLarge: return "accXLarge"
        case .accessibilityExtraExtraLarge: return "accXXLarge"
        case .accessibilityExtraExtraExtraLarge: return "accXXXLarge"
        default: return "default"
        }
    }
    
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
        HorizonUI.registerCustomFonts()
        OfflineModeAssembly.mock(OfflineModeInteractorMock(mockIsFeatureFlagEnabled: false))
        Clock.reset()
        API.resetMocks()
        LoginSession.clearAll()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        environment = TestEnvironment()
        AppEnvironment.shared = environment
        environment.app = .horizon
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
