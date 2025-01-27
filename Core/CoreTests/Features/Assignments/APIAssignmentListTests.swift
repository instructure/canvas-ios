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
@testable import Core

class AssignmentFilterTests: XCTestCase {
    func testEncode() {
        func asDict(_ filter: AssignmentFilter) -> [String: String?] {
            try! JSONSerialization.jsonObject(with: JSONEncoder().encode(filter)) as! [String: String?]
        }

        XCTAssertEqual(asDict(.allGradingPeriods), ["gradingPeriodId": nil])
        XCTAssertEqual(asDict(.gradingPeriod(id: "id")), ["gradingPeriodId": "id"])
    }

    func testDecode() {
        func fromDict(_ data: [String: String?]) -> AssignmentFilter {
            try! JSONDecoder().decode(AssignmentFilter.self, from: JSONSerialization.data(withJSONObject: data))
        }

        XCTAssertEqual(fromDict(["gradingPeriodId": nil]), .allGradingPeriods)
        XCTAssertEqual(fromDict(["gradingPeriodId": "id"]), .gradingPeriod(id: "id"))
    }
}

class AssignmentListRequestableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Clock.reset()
    }

    func testDecode() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let assignmentDueDate = Date(fromISOString: "2019-04-18T23:59:59-06:00")

        let grp1 = APIAssignmentListGroup.make(id: "1", name: "Group A", assignments: [
            APIAssignmentListAssignment.make(dueAt: assignmentDueDate, quizID: "1")
        ])

        let strGrps = String(data: try! encoder.encode([grp1]), encoding: .utf8)!

        let str = """
        {
         "data": {
           "course": {
             "name": "CourseName",
             "groups": {
               "nodes": \(strGrps)
             }
           }
         }
        }
        """
        let data = str.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var model: APIAssignmentListResponse?
        do {
            model = try decoder.decode(APIAssignmentListResponse.self, from: data!)
        } catch {
            print("error: \(error)")
            XCTFail("decode failed  \(error.localizedDescription)")
        }

        XCTAssertNotNil(model)
        XCTAssertEqual(model?.groups.count, 1)
        XCTAssertEqual(model?.groups.first?.assignments.count, 1)

        let group = model?.groups.first
        XCTAssertEqual(group?.name, "Group A")
        XCTAssertEqual(group?.id, "1")

        let a = model?.groups.first?.assignments.first

        XCTAssertEqual(a?.name, "A")
        XCTAssertEqual(a?.dueAt, assignmentDueDate)
        XCTAssertEqual(a?.quizID, "1")
    }

    func testIconForDiscussion() {
        let a = APIAssignmentListAssignment.make(submissionTypes: [.discussion_topic])
        let icon = a.icon
        let expected = UIImage.discussionLine
        XCTAssertEqual(icon, expected)
    }

    func testIconForAssignment() {
        let a = APIAssignmentListAssignment.make()
        let icon = a.icon
        let expected = UIImage.assignmentLine
        XCTAssertEqual(icon, expected)
    }

    func testIconForQuiz() {
        let a = APIAssignmentListAssignment.make(quizID: "1")
        let icon = a.icon
        let expected = UIImage.quizLine
        XCTAssertEqual(icon, expected)
    }

    func testIconForExternalTool() {
        let a = APIAssignmentListAssignment.make(submissionTypes: [.external_tool])
        let icon = a.icon
        let expected = UIImage.ltiLine
        XCTAssertEqual(icon, expected)
    }

    func testIconForLocked() {
        let a = APIAssignmentListAssignment.make(lockAt: Clock.now.inCalendar.addDays(-1), submissionTypes: [.external_tool])
        let icon = a.icon
        let expected = UIImage.lockLine
        XCTAssertEqual(icon, expected)
    }

    func testFormattedDueDate() {
        let isoString = "2037-06-01T05:59:00Z"
        let date = Date(fromISOString: isoString)!
        let aa = APIAssignmentListAssignment.make(dueAt: date)
        XCTAssertEqual(aa.formattedDueDate, "Due \(date.relativeDateTimeString)")
    }

    func testFormattedDueDateNoDueDate() {
        let aa = APIAssignmentListAssignment.make()
        XCTAssertEqual(aa.formattedDueDate, "No Due Date")
    }

    func testFormattedDueDateAvailabilityClosed() {
        let lockAt = Clock.now.inCalendar.addDays(-5)
        let aa = APIAssignmentListAssignment.make(lockAt: lockAt)
        XCTAssertEqual(aa.formattedDueDate, "Availability: Closed")
    }
}
