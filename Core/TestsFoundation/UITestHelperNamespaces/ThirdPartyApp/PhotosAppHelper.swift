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
import XCTest

public class PhotosAppHelper: BaseHelper {
    static let defaultTimeout = TimeInterval(10)
    public static let photosApp = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")

    public static func launch() {
        photosApp.launch()
        photosApp.hit()
        tapContinue()
    }

    public static func tapContinue() {
        let continueButton = photosApp.descendants(matching: .button).matching(label: "Continue").firstMatch
        guard continueButton.waitForExistence(timeout: 5) else { return }
        continueButton.tap()
    }

    public static func tapFirstPicture() {
        let thePhoto = photosApp.descendants(matching: .image).matching(labelContaining: "Photo, March").firstMatch
        photosApp.actionUntilElementCondition(action: .swipeDown(.onElement), element: thePhoto, condition: .visible, timeout: 5)
        guard thePhoto.waitForExistence(timeout: defaultTimeout) else { return }
        thePhoto.tap()
    }

    public static func tapShare() {
        let share = photosApp.descendants(matching: .button).matching(label: "Share").firstMatch
        guard share.waitForExistence(timeout: defaultTimeout) else { return }
        share.tap()
    }

    public static func tapCanvasButton() {
        let canvas = photosApp.descendants(matching: .any).matching(labelContaining: "Canvas").firstMatch
        guard canvas.waitForExistence(timeout: defaultTimeout) else { return }
        canvas.tap()
    }

    public static func selectCourse(course: DSCourse) {
        let courseSelector = photosApp.descendants(matching: .button).matching(label: "Select course").firstMatch
        guard courseSelector.waitForExistence(timeout: defaultTimeout) else { return }
        courseSelector.tap()

        let theCourse = photosApp.descendants(matching: .button).matching(label: course.name).firstMatch
        guard theCourse.waitForExistence(timeout: defaultTimeout) else { return }
        theCourse.tap()
    }

    public static func selectAssignment(assignment: DSAssignment) {
        let assignmentSelector = photosApp.descendants(matching: .button).matching(label: "Select assignment").firstMatch
        guard assignmentSelector.waitForExistence(timeout: defaultTimeout) else { return }
        assignmentSelector.tap()

        let theAssignment = photosApp.descendants(matching: .button).matching(label: assignment.name).firstMatch
        guard theAssignment.waitForExistence(timeout: defaultTimeout) else { return }
        theAssignment.tap()
    }

    public static func tapSubmitButton() {
        let submit = photosApp.descendants(matching: .button).matching(label: "Submit").firstMatch
        guard submit.waitForExistence(timeout: defaultTimeout) else { return }
        submit.tap()
    }

    public static func tapDoneButton() {
        let done = photosApp.descendants(matching: .button).matching(label: "Done").firstMatch
        guard done.waitForExistence(timeout: defaultTimeout) else { return }
        done.tap()
    }

    public static func closeApp() {
        photosApp.terminate()
    }
}
