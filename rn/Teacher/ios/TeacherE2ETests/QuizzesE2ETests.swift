//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class QuizzesE2ETests: CoreUITestCase {
    func testQuizzesE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()
        app.find(label: "Quiz One").tap()
        QuizDetails.previewQuiz.waitToExist()
        QuizDetails.previewQuiz.tap()
        app.find(label: "Quiz Preview").waitToExist()
        app.find(label: "Preview").waitToExist()
        app.find(label: "Preview").tap()
        app.find(label: "Quiz Instructions").waitToExist()
        app.find(label: "This is question A").waitToExist()
        XCTAssertTrue(app.find(labelContaining: "This is a preview of the published version of the quiz").exists())
        app.find(label: "Done").tap()
        QuizDetails.previewQuiz.waitToExist()
        app.find(label: "Edit").waitToExist()
        app.find(label: "Edit").tap()
        app.find(labelContaining: "Edit Quiz Details").waitToExist()
        XCTAssertTrue(app.find(labelContaining: "Shuffle Answers").exists())
        app.find(label: "Done").tap()
        app.find(labelContaining: "Edit Quiz Details").waitToVanish()
    }
}
