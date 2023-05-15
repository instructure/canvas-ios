//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class PhotosHelper {
    let defaultTimeout = TimeInterval(10)
    public let photosApp = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")

    public init () {}

    public func launch() {
        photosApp.launch()
        photosApp.tap()
        tapContinue()
    }

    public func tapContinue() {
        if photosApp.buttons["Continue"].waitForExistence(timeout: 5) {
            photosApp.buttons["Continue"].tap()
        }
    }

    public func tapFirstPicture() {
        if photosApp.collectionViews["PhotosGridView"].cells.firstMatch.waitForExistence(timeout: defaultTimeout) {
            photosApp.collectionViews["PhotosGridView"].cells.firstMatch.tap()
        }
    }

    public func tapShare() {
        if photosApp.buttons["Share"].waitForExistence(timeout: defaultTimeout) {
            photosApp.buttons["Share"].tap()
        }
    }

    public func tapCanvasButton() {
        let elements = photosApp
            .descendants(matching: .any)
            .matching(NSPredicate(format: "label == 'XCElementSnapshotPrivilegedValuePlaceholder'"))
            .allElementsBoundByIndex

        if elements[3].waitForExistence(timeout: defaultTimeout) {
            elements[3].tap()
        }
    }

    public func selectCourse(course: DSCourse) {
        if photosApp.buttons["Select course"].waitForExistence(timeout: defaultTimeout) {
            photosApp.buttons["Select course"].tap()
        }

        if photosApp.buttons[course.name].waitForExistence(timeout: defaultTimeout) {
            photosApp.buttons[course.name].tap()
        }
    }

    public func selectAssignment(assignment: DSAssignment) {
        if photosApp.buttons["Select assignment"].waitForExistence(timeout: defaultTimeout) {
            photosApp.buttons["Select assignment"].tap()
        }

        if photosApp.buttons[assignment.name].waitForExistence(timeout: defaultTimeout) {
            photosApp.buttons[assignment.name].tap()
        }
    }

    public func tapSubmitButton() {
        if photosApp.buttons["Submit"].waitForExistence(timeout: defaultTimeout) {
            photosApp.buttons["Submit"].tap()
        }
    }

    public func tapDoneButton() {
        if photosApp.buttons["Done"].waitForExistence(timeout: defaultTimeout) {
            photosApp.buttons["Done"].tap()
        }
    }

    public func closeApp() {
        photosApp.terminate()
    }
}
