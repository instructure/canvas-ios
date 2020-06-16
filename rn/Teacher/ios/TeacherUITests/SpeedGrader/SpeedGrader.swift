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
import TestsFoundation
import XCTest
@testable import CoreUITests

public enum SpeedGrader: String, RawElementWrapper {
    case doneButton = "header.navigation-done"
    case gradePickerButton = "grade-picker.button"

    public static func segmentButton(label: String) -> Element {
        let segmentControl = app.find(id: "speedgrader.segment-control").waitToExist()
        return segmentControl.rawElement.buttons.matching(label: label).firstElement
    }

    static func userName(userID: String) -> Element {
        return app.find(id: "header.context.button.\(userID)")
    }

    static func dismissTutorial() {
        let button = app.find(idStartingWith: "tutorial.button")
        while button.rawElement.waitForExistence(timeout: 3) {
            button.tap()
        }
    }
}
