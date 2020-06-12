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
    func testQuizQuestionsNoMoreNativeView() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()

        app.find(labelContaining: "Quiz One").tap()
        Quiz.takeButton.tapUntil {
            app.find(label: "Instructions").exists
        }
        app.find(label: "This is the first quiz.").waitToExist()
    }

    func testQuizQuestionsOpenInWebView() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()

        app.find(labelContaining: "Web Quiz").tap()
        Quiz.takeButton.tapUntil {
            app.find(label: "Instructions").exists
        }
        app.find(label: "This quiz is for testing web view question types.").waitToExist()
    }

    func testQuizzesShowEmptyState() {
        Dashboard.courseCard(id: "262").tap()
        CourseNavigation.announcements.waitToExist()
        CourseNavigation.quizzes.waitToVanish()
    }
}
