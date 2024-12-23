//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest
import TestsFoundation

class CoreActivityViewControllerTests: CoreTestCase {

    func testDismissesItselfWhenAppMovesToBackground() {
        // MARK: - GIVEN
        let host = UIViewController()
        let testee = CoreActivityViewController(activityItems: [""], applicationActivities: nil)
        window.rootViewController = host
        host.present(testee, animated: false)
        waitUntil(shouldFail: true) {
            testee.view.superview != nil
        }
        XCTAssertEqual(host.presentedViewController, testee)

        // MARK: - WHEN
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)

        // MARK: - THEN
        waitUntil(shouldFail: true) {
            host.presentedViewController == nil
        }
    }

    func testDoNotDismissWhenAnotherViewControllerIsPresented() {
        // MARK: - GIVEN
        let host = UIViewController()
        let testee = CoreActivityViewController(activityItems: [""], applicationActivities: nil)
        let presentedOnTestee = UIViewController()
        window.rootViewController = host
        host.present(testee, animated: false)
        waitUntil(shouldFail: true) {
            testee.view.superview != nil
        }
        testee.present(presentedOnTestee, animated: false)
        XCTAssertEqual(host.presentedViewController, testee)
        waitUntil(shouldFail: true) {
            testee.presentedViewController == presentedOnTestee
        }

        // MARK: - WHEN
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)

        // MARK: - THEN
        RunLoop.main.run(until: Date() + 1)
        XCTAssertEqual(host.presentedViewController, testee)
        XCTAssertEqual(testee.presentedViewController, presentedOnTestee)
    }
}
