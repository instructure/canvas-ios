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

import TestsFoundation
@testable import Core

class SpeedGraderFilesUITests: MiniCanvasUITestCase {
    lazy var student = mocked.students.first!
    lazy var submission = firstAssignment.submission(byUserId: student.id.value)!

    func showSubmission() {
        show("/courses/\(firstCourse.id)/assignments/\(firstAssignment.id)/submissions/\(submission.api.id)")
        SpeedGrader.dismissTutorial()
    }

    func testShowFile() throws {
        MiniCanvasServer.shared.server.logResponses = true

        let student = mocked.students.first!

        let pdf = try Data(contentsOf: Bundle(for: Self.self).url(forResource: "instructure", withExtension: "pdf")!)
        let file1 = mocked.addDocument(name: "instructure.pdf", contents: pdf)
        let file2 = mocked.addFile(name: "dashboard.png", contents: UIImage.dashboardSolid.pngData()!)
        let submission = MiniSubmission(
            APISubmission.make(
                id: mocked.nextId(),
                assignment_id: firstAssignment.api.id,
                user_id: student.id,
                submission_type: .online_upload,
                workflow_state: .submitted,
                attempt: 1,
                attachments: [
                    file1.api,
                    file2.api,
                ],
                user: student
            )
        )

        firstAssignment.submissions = [submission]
        firstAssignment.api.submission = [submission.api]

        showSubmission()
        SpeedGrader.Segment.files.tap()

        let dashboardPngRequested = MiniCanvasServer.shared.expectationForRequest("/files/\(file2.id)")
        app.find(label: "dashboard.png").tap()
        wait(for: [dashboardPngRequested], timeout: 5)
    }
}
