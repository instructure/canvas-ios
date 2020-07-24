//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Core
import TestsFoundation

class GradeListTests: CoreUITestCase {
    func testAssignmentDetailsCompose() {
        let courseCell = Courses.course(id: "263")
        courseCell.tapUntil { !courseCell.exists }
        GradeList.cell(assignmentID: "1831").tap()
        app.find(labelContaining: "This is assignment one.").waitToExist()
        AssignmentDetails.replyButton.tap()

        XCTAssertEqual(Compose.recipientName(id: "837").label(), "Teacher One")
        XCTAssertEqual(Compose.subject.value(), "Regarding: Student One, Assignment - Assignment One")
    }
}
