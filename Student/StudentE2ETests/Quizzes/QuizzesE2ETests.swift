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
@testable import TestsFoundation
@testable import CoreUITests
@testable import Core

class QuizzesE2ETests: CoreUITestCase {
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
        XCTAssertEqual(app.textFields.firstElement.value(), "42.000000")
    }

    func testQuizQuestionsOpenInWebView() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()

        app.find(labelContaining: "Web Quiz").tap()
        Quiz.resumeButton.tap()
        app.find(label: "This quiz is for testing web view question types.").waitToExist()
    }

    func testQuizzesShowEmptyState() {
        Dashboard.courseCard(id: "262").tap()
        CourseNavigation.announcements.waitToExist()
        CourseNavigation.quizzes.waitToVanish()
    }
}
