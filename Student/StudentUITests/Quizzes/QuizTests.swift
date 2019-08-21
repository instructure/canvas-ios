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

import XCTest
import TestsFoundation
@testable import CoreUITests

class QuizTests: CoreUITestCase {
    func testQuizQuestionsOpenInNativeView() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()

        app.find(labelContaining: "Quiz One").tap()
        Quiz.resumeButton.tap()

        Quiz.text(string: "This is question A").waitToExist()
        Quiz.text(string: "True").waitToExist()

        Quiz.text(string: "This is question B").waitToExist()
        Quiz.text(string: "Answer B.1").waitToExist()

        app.swipeUp()

        Quiz.text(string: "This is question C").waitToExist()
        Quiz.text(string: "Answer 1.A").waitToExist()

        Quiz.text(string: "This is question D").waitToExist()
        XCTAssertEqual(XCUIElementWrapper(app.textFields.firstMatch).value, "42.000000")
    }

    func testQuizQuestionsOpenInWebView() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()

        app.find(labelContaining: "Web Quiz").tap()
        Quiz.resumeButton.tap()
        app.find(label: "Resume Quiz").tap() // in web view

        Quiz.text(string: "Question 1").waitToExist()
        Quiz.text(string: "Question 2").waitToExist()
        let textFields = app.textFields.allElementsBoundByIndex
        for textField in textFields {
            if let value = textField.value as? String {
                XCTAssert(value == "Fox" || value == "Dog" || value == "6.4")
            } else {
                XCTAssert(false, "text field did not have a value")
            }
        }
    }

    func testQuizzesShowEmptyState() {
        Dashboard.courseCard(id: "262").tap()
        CourseNavigation.announcements.waitToExist()
        CourseNavigation.quizzes.waitToVanish()
    }
}
