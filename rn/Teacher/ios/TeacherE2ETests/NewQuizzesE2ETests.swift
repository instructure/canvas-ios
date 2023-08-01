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

class NewQuizzesE2ETests: CoreUITestCase {
    func testNewQuizzesE2E() {
        DashboardHelper.courseCard(courseId: "399").hit()
        CourseDetailsHelper.cell(type: .quizzes).hit()
        app.find(label: "Read-only Quiz").hit()
        QuizzesHelper.Details.launchExternalToolButton.hit()
        XCTAssertTrue(app.find(labelContaining: "This is an essay question").waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "Please don't put text in this box.").waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "More Quiz Actions").waitUntil(condition: .visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "Toolbar").waitUntil(condition: .visible).isVisible)
        app.find(label: "Done").hit()
        XCTAssertFalse(app.find(labelContaining: "This is an essay question").waitUntil(condition: .vanish).isVisible)
        XCTAssertFalse(app.find(labelContaining: "Toolbar").waitUntil(condition: .vanish).isVisible)
    }
}
