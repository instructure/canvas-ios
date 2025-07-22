//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Core
import CoreData

class GetCustomGradeStatusesTests: CoreTestCase {

    func testItCreatesCustomStatuses() {
        let apiResponse = GetCustomGradeStatusesRequest
            .Response(
                data: .init(
                    course: .init(
                        customGradeStatusesConnection: .init(
                            nodes: [
                                .init(name: "Good", id: "22"),
                                .init(name: "Excellent", id: "33"),
                                .init(name: "Very good", id: "44")
                            ]
                        )
                    )
                )
            )

        let courseID = "23443"
        GetCustomGradeStatuses(courseID: courseID).write(response: apiResponse, urlResponse: nil, to: databaseClient)

        let customStatuses: [CustomGradeStatus] = databaseClient.fetch(scope: .all(orderBy: "id"))
        XCTAssertEqual(customStatuses.count, 3)

        XCTAssertEqual(customStatuses[0].id, "22")
        XCTAssertEqual(customStatuses[0].name, "Good")
        XCTAssertEqual(customStatuses[0].courseID, courseID)

        XCTAssertEqual(customStatuses[1].id, "33")
        XCTAssertEqual(customStatuses[1].name, "Excellent")
        XCTAssertEqual(customStatuses[1].courseID, courseID)

        XCTAssertEqual(customStatuses[2].id, "44")
        XCTAssertEqual(customStatuses[2].name, "Very good")
        XCTAssertEqual(customStatuses[2].courseID, courseID)
    }

    func testSubmissionsUpdate() {
        let submission1 = Submission(context: databaseClient)
        submission1.customGradeStatusId = "33"
        submission1.customGradeStatusName = nil

        let submission2 = Submission(context: databaseClient)
        submission2.customGradeStatusId = "33"
        submission2.customGradeStatusName = "Old name"

        let apiResponse = GetCustomGradeStatusesRequest
            .Response(
                data: .init(
                    course: .init(
                        customGradeStatusesConnection: .init(
                            nodes: [
                                .init(name: "Excellent", id: "33")
                            ]
                        )
                    )
                )
            )

        GetCustomGradeStatuses(courseID: "23443")
            .write(response: apiResponse, urlResponse: nil, to: databaseClient)

        let customStatuses: [CustomGradeStatus] = databaseClient.fetch()
        XCTAssertEqual(customStatuses.count, 1)

        XCTAssertEqual(customStatuses[0].id, "33")
        XCTAssertEqual(customStatuses[0].name, "Excellent")
        XCTAssertEqual(customStatuses[0].courseID, "23443")

        XCTAssertEqual(submission1.customGradeStatusName, "Excellent")
        XCTAssertEqual(submission2.customGradeStatusName, "Excellent")
    }

    func testSubmissionFetch() throws {
        let customStatus = CustomGradeStatus(context: databaseClient)
        customStatus.id = "44"
        customStatus.name = "Very good"

        GetSubmissions(context: .course("23443"), assignmentID: "123")
            .write(response: [.make(custom_grade_status_id: "44")], urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        let submission = try XCTUnwrap(submissions.first)

        XCTAssertEqual(submission.customGradeStatusName, "Very good")
    }
}
