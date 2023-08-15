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

import TestsFoundation

class QuizzesE2ETests: CoreUITestCase {
    func testQuizzesE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .quizzes).hit()
        app.find(label: "Quiz One").hit()
        QuizzesHelper.Details.previewQuiz.hit()
        XCTAssertTrue(app.find(label: "Quiz Preview").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(label: "Preview").waitUntil(.visible).isVisible)
        app.find(label: "Preview").hit()
        XCTAssertTrue(app.find(label: "Quiz Instructions").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(label: "This is question A").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "This is a preview of the published version of the quiz").waitUntil(.visible).isVisible)
        app.find(label: "Done").hit()
        XCTAssertTrue(QuizzesHelper.Details.previewQuiz.waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(label: "Edit").waitUntil(.visible).isVisible)
        app.find(label: "Edit").hit()
        XCTAssertTrue(app.find(labelContaining: "Edit Quiz Details").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "Shuffle Answers").waitUntil(.visible).isVisible)
        app.find(label: "Done").hit()
        XCTAssertFalse(app.find(labelContaining: "Edit Quiz Details").waitUntil(.vanish).isVisible)
    }
}
