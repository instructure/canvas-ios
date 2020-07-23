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
        let offset: CGVector
        switch XCUIDevice.shared.orientation {
        case .portrait:
            offset = CGVector(dx: x, dy: y)
        case .portraitUpsideDown:
            offset = CGVector(dx: 1 - x, dy: 1 - y)
        case .landscapeLeft:
            offset = CGVector(dx: 1 - y, dy: x)
        case .landscapeRight:
            offset = CGVector(dx: y, dy: 1 - x)
        default:
            fatalError("Unknown orientation")
        }
        return sbApp.coordinate(withNormalizedOffset: offset)
    }

    public func moveSplit(toFraction fraction: CGFloat) {
        let divider = sbApp.find(id: "SideAppDivider")
        let dest = relativeCoordinate(x: fraction, y: 0.5)
        divider.center.press(forDuration: 0, thenDragTo: dest)
        sleep(1)
    }

    func resetMultitasking() {
        if sbApp.find(id: "SideAppDivider").exists {
            moveSplit(toFraction: 1)
        }
        app.activate()
    }

    func bringUpDock() {
        let start = relativeCoordinate(x: 0.5, y: 1.0)
        let dest = relativeCoordinate(x: 0.5, y: 0.9)
        start.press(forDuration: 0, thenDragTo: dest)
    }

    internal func hideSafariKeyboard() {
        let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        let button = safariApp.keyboards.buttons.matching(label: "Hide keyboard").firstMatch

        guard button.exists else { return }

        // check to see if it's off screen
        let frame = button.frame
        let screen = sbApp.frame

        // comparing x against height is intentional. The frames are in different coordinate spaces
        guard frame.midX > 0, frame.midX < screen.height,
            frame.midY > 0, frame.midY < screen.height else { return }

        button.tap()
    }

    public func setupSplitScreenWithSafariOnRight() {
        resetMultitasking()

        bringUpDock()

        let dock = sbApp.find(id: "user icon list view")
        let safari = dock.rawElement.find(id: "Safari")
        let dest = relativeCoordinate(x: 0.99, y: 0.5)
        safari.center.press(forDuration: 0.5, thenDragTo: dest)
        sleep(2)
        hideSafariKeyboard()
    }
}
