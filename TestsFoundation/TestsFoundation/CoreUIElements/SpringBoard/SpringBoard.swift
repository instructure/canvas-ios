//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class SpringBoard {
    private init() {}
    public static let shared = SpringBoard()

    public let sbApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    func relativeCoordinate(x: CGFloat, y: CGFloat) -> XCUICoordinate {
        sbApp.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
    }

    public func moveSplit(toFraction fraction: CGFloat) {
        let divider = sbApp.find(id: "SideAppDivider", type: XCUIElement.ElementType.other)
        let dest = relativeCoordinate(x: fraction, y: 0.5)
        divider.center.press(forDuration: 0, thenDragTo: dest)
        sleep(1)
    }

    func resetMultitasking() {
        if sbApp.find(id: "SideAppDivider", type: XCUIElement.ElementType.other).exists {
            moveSplit(toFraction: 1)
        }
        app.activate()
    }

    func bringUpDock() {
        let start = relativeCoordinate(x: 0.5, y: 1.0)
        let dest = relativeCoordinate(x: 0.5, y: 0.9)
        start.press(forDuration: 1, thenDragTo: dest)
    }

    internal func hideSafariKeyboard() {
        let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        let button = safariApp.keyboards.buttons.matching(label: "Hide keyboard").firstMatch

        guard button.exists else { return }

        button.tap()
    }

    public func setupSplitScreenWithSafariOnRight() {
        resetMultitasking()

        var splitViewButtonID = ""
        if Bundle.main.isTeacherTestsRunner {
            splitViewButtonID = "top-affordance:\(Bundle.teacherBundleID)"
        } else if Bundle.main.isStudentTestsRunner {
            splitViewButtonID = "top-affordance:\(Bundle.studentBundleID)"
        }

        SpringBoard.shared.sbApp.buttons[splitViewButtonID].forceTapElement()
        SpringBoard.shared.sbApp.buttons["top-affordance-split-view-button"].forceTapElement()
        SpringBoard.shared.sbApp.icons["Safari"].tap()

        sleep(2)
        hideSafariKeyboard()
    }
}
