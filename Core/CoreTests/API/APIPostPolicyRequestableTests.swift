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

class PostAssignmentGradesPostPolicyRequestTests: XCTestCase {
    var req: PostAssignmentGradesPostPolicyRequest!

    override func setUp() {
        super.setUp()
        req = PostAssignmentGradesPostPolicyRequest(assignmentID: "1", postPolicy: .everyone)
    }
    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testQuery() {
        let expected = """
        mutation PostAssignmentGrades\n    {\n        postAssignmentGrades(input: {assignmentId: \"1\", gradedOnly: false})\n        {\n            assignment { id }\n        }\n    }
        """
        XCTAssertEqual(req.query, expected)
    }

    func testQueryWithSectionIDs() {
        let sectionIDReq = PostAssignmentGradesPostPolicyRequest(assignmentID: "1", postPolicy: .everyone, sections: [ "2", "3" ])
        // swiftlint:disable line_length
        let expected = """
        mutation PostAssignmentGrades\n    {\n        postAssignmentGradesForSections(input: {assignmentId: \"1\", gradedOnly: false, sectionIds: [ \"2\",\"3\" ]})\n        {\n            assignment { id }\n        }\n    }
        """
        // swiftlint:enable line_length
        XCTAssertEqual(sectionIDReq.query, expected)
    }
}

class HideAssignmentGradesPostPolicyRequestTests: XCTestCase {
    var req: HideAssignmentGradesPostPolicyRequest!

    override func setUp() {
        super.setUp()
        req = HideAssignmentGradesPostPolicyRequest(assignmentID: "1")
    }

    func testQuery() {
        let expected = """
        mutation HideAssignmentGrades\n{\n    hideAssignmentGrades(input: {assignmentId: \"1\"})\n    {\n        assignment { id }\n    }\n}
        """
        XCTAssertEqual(req.query, expected)
    }

    func testQueryWithSectionIDs() {
        let sectionIDReq = HideAssignmentGradesPostPolicyRequest(assignmentID: "1", sections: [ "2", "3" ])
        let expected = """
        mutation HideAssignmentGrades\n{\n    hideAssignmentGradesForSections(input: {assignmentId: \"1\", sectionIds: [ \"2\",\"3\" ]})\n    {\n        assignment { id }\n    }\n}
        """
        XCTAssertEqual(sectionIDReq.query, expected)
    }
}

class GetAssignmentPostPolicyInfoRequestTests: XCTestCase {
    var req: GetAssignmentPostPolicyInfoRequest!

    override func setUp() {
        super.setUp()
        req = GetAssignmentPostPolicyInfoRequest(courseID: "1", assignmentID: "1")
    }
    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testQuery() {
        // swiftlint:disable line_length
        let expected = """
        query GetAssignmentPostPolicyInfo {\n    course(id: \"1\") {\n        sections: sectionsConnection {\n          nodes {\n            id\n            name\n          }\n        }\n      }\n      assignment(id: \"1\") {\n        submissions: submissionsConnection {\n          nodes {\n            score\n            excused\n            state\n            postedAt\n          }\n        }\n      }\n}
        """
        // swiftlint:enable line_length
        XCTAssertEqual(req.query, expected)
    }
}
