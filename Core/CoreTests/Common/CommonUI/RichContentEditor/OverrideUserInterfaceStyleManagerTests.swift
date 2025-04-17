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

@testable import Core
import XCTest

final class OverrideUserInterfaceStyleManagerTests: CoreTestCase {

    private var testee: OverrideUserInterfaceStyleManager!
    private var host: UIView!

    override func setUp() {
        super.setUp()
        host = .init()
        testee = .init(host: host)
    }

    override func tearDown() {
        host = nil
        testee = nil
        super.tearDown()
    }

    func test_init_whenHostIsViewController_shouldSetViewAsHost() {
        let host = UIViewController()
        testee = .init(host: host)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .unspecified)

        testee.setOverrideStyle(.dark)
        XCTAssertEqual(host.view.overrideUserInterfaceStyle, .dark)
    }

    func test_setOverrideStyle() {
        // initial state
        XCTAssertEqual(host.overrideUserInterfaceStyle, .unspecified)

        testee.setOverrideStyle(.dark)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .dark)
    }

    // MARK: - Observation

    func test_setup_shouldStartObservation() {
        var actionInput: UIUserInterfaceStyle?
        let action: (UIUserInterfaceStyle) -> Void = { actionInput = $0 }
        testee.setup(currentStyle: .unspecified, additionalAction: action)

        triggerStyleDidChangeNotification(to: .light)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .light)
        XCTAssertEqual(actionInput, .light)

        triggerStyleDidChangeNotification(to: .dark)
        XCTAssertEqual(host.overrideUserInterfaceStyle, .dark)
        XCTAssertEqual(actionInput, .dark)
    }

    func test_setup_whenCalledTwice_shouldStartObservationOnlyOnce() {
        var action1CallsCount = 0
        let action1: (UIUserInterfaceStyle) -> Void = { _ in action1CallsCount += 1 }
        var action2CallsCount = 0
        let action2: (UIUserInterfaceStyle) -> Void = { _ in action2CallsCount += 1 }

        // setup with action1 -> obbserver should call action1
        testee.setup(currentStyle: .unspecified, additionalAction: action1)
        triggerStyleDidChangeNotification(to: .light)
        XCTAssertEqual(action1CallsCount, 1)
        XCTAssertEqual(action2CallsCount, 0)

        // setup with action2 -> obbserver should no longer call action1
        testee.setup(currentStyle: .unspecified, additionalAction: action2)
        triggerStyleDidChangeNotification(to: .dark)
        XCTAssertEqual(action1CallsCount, 1)
        XCTAssertEqual(action2CallsCount, 1)
    }
}

// MARK: - Helpers

private extension OverrideUserInterfaceStyleManagerTests {
    func triggerStyleDidChangeNotification(to style: UIUserInterfaceStyle) {
        NotificationCenter.default.post(
            name: .windowUserInterfaceStyleDidChange,
            object: nil,
            userInfo: ["style": style]
        )
    }
}
