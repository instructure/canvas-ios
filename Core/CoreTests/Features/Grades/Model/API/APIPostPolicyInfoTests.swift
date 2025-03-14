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

class APIPostPolicyInfoTests: XCTestCase {
    func testSubmissionNodeIsPosted() {
        let node = APIPostPolicy.AssignmentInfo.SubmissionNode(
            score: 0.5, excused: false, state: "graded", postedAt: Date()
        )
        XCTAssertTrue(node.isPosted)
    }

    func testSubmissionNodeIsNotPosted() {
        let node = APIPostPolicy.AssignmentInfo.SubmissionNode(
            score: 0.5, excused: false, state: "graded", postedAt: nil
        )
        XCTAssertFalse(node.isPosted)
    }

    func testSubmissionNodeIsHidden() {
        let node = APIPostPolicy.AssignmentInfo.SubmissionNode(
            score: 0.5, excused: false, state: "graded", postedAt: nil
        )
        XCTAssertTrue(node.isHidden)
    }

    func testSubmissionNodeIsHiddenWhenExcused() {
        let node = APIPostPolicy.AssignmentInfo.SubmissionNode(
            score: nil, excused: true, state: "not graded", postedAt: nil
        )
        XCTAssertTrue(node.isHidden)
    }

    func testSubmissionNodeIsNotHidden() {
        let node = APIPostPolicy.AssignmentInfo.SubmissionNode(
            score: 0.5, excused: false, state: "graded", postedAt: Date()
        )
        XCTAssertFalse(node.isHidden)
    }

    func test_course_sections_decode() {
        let str = """
        {
            "data": {
                "course": {
                    "sections": {
                        "nodes": [{
                            "id": "1",
                            "name": "Quiz Questions"
                        }],
                        "pageInfo": {
                            "endCursor": "example_cursor",
                            "hasNextPage": true
                        }
                    }
                }
            }
        }
        """
        let data = str.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let model = try? decoder.decode(APIPostPolicy.CourseInfo.self, from: data!)

        XCTAssertNotNil(model)
        XCTAssertEqual(model?.page.count, 1)

        let section = model?.page.first
        XCTAssertEqual(section?.name, "Quiz Questions")
        XCTAssertEqual(section?.id, "1")

        let pageInfo = model?.pageInfo
        XCTAssertEqual(pageInfo?.endCursor, "example_cursor")
        XCTAssertEqual(pageInfo?.hasNextPage, true)
    }

    func test_submissions_decode() {
        let str = """
        {
            "data": {
                "assignment": {
                    "submissions": {
                        "nodes": [{
                            "score": 0.5,
                            "excused": false,
                            "state": "graded",
                            "postedAt": "2019-08-22T07:28:44-06:00"
                        }]
                    }
                }
            }
        }
        """

        let data = str.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let model = try? decoder.decode(APIPostPolicy.AssignmentInfo.self, from: data!)

        XCTAssertNotNil(model)
        XCTAssertEqual(model?.nodes.count, 1)

        let submission = model?.nodes.first
        XCTAssertEqual(submission?.score, 0.5)
        XCTAssertEqual(submission?.state, "graded")
        XCTAssertEqual(submission?.excused, false)
        XCTAssertEqual(submission?.postedAt, Date(fromISOString: "2019-08-22T07:28:44-06:00"))
    }
}

class PostAssignmentGradesPostPolicyRequestTests: XCTestCase {
    var req: PostAssignmentGradesPostPolicyRequest!

    override func setUp() {
        super.setUp()
        req = .init(assignmentID: "1", postPolicy: .everyone)
    }

    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testBody() {
        req.assertBodyEquals(GraphQLBody(
            query: PostAssignmentGradesPostPolicyRequest.query,
            operationName: "PostAssignmentGradesPostPolicyRequest",
            variables: .init(input: .init(gradedOnly: false, assignmentId: "1", sectionIds: nil))
        ))
    }
}

class PostAssignmentGradesForSectionsPostPolicyRequestTests: XCTestCase {
    var req: PostAssignmentGradesForSectionsPostPolicyRequest!

    override func setUp() {
        super.setUp()
        req = .init(assignmentID: "1", postPolicy: .everyone, sections: [ "2", "3" ])
    }

    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testBody() {
        req.assertBodyEquals(GraphQLBody(
            query: PostAssignmentGradesForSectionsPostPolicyRequest.query,
            operationName: "PostAssignmentGradesForSectionsPostPolicyRequest",
            variables: .init(input: .init(gradedOnly: false, assignmentId: "1", sectionIds: [ "2", "3" ]))
        ))
    }
}

class HideAssignmentGradesPostPolicyRequestTests: XCTestCase {
    var req: HideAssignmentGradesPostPolicyRequest!

    override func setUp() {
        super.setUp()
        req = .init(assignmentID: "1")
    }

    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testBody() {
        req.assertBodyEquals(GraphQLBody(
            query: HideAssignmentGradesPostPolicyRequest.query,
            operationName: "HideAssignmentGradesPostPolicyRequest",
            variables: .init(input: .init(assignmentId: "1", sectionIds: nil))
        ))
    }
}

class HideAssignmentGradesForSectionPostPolicyRequestTests: XCTestCase {
    var req: HideAssignmentGradesForSectionsPostPolicyRequest!

    override func setUp() {
        super.setUp()
        req = .init(assignmentID: "1", sections: [ "2", "3" ])
    }

    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testBody() {
        req.assertBodyEquals(GraphQLBody(
            query: HideAssignmentGradesForSectionsPostPolicyRequest.query,
            operationName: "HideAssignmentGradesForSectionsPostPolicyRequest",
            variables: .init(input: .init(assignmentId: "1", sectionIds: [ "2", "3"]))
        ))
    }
}

class GetPostPolicyCourseSectionsRequestTests: XCTestCase {
    var req: GetPostPolicyCourseSectionsRequest!

    override func setUp() {
        super.setUp()
        req = .init(courseID: "1")
    }
    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testBody() {
        req.assertBodyEquals(GraphQLBody(
            query: GetPostPolicyCourseSectionsRequest.query,
            operationName: "GetPostPolicyCourseSectionsRequest",
            variables: .init(
                courseID: "1",
                cursor: nil,
                pageSize: 20
            )
        ))
    }
}

class GetPostPolicyAssignmentSubmissionsRequestTests: XCTestCase {
    var req: GetPostPolicyAssignmentSubmissionsRequest!

    override func setUp() {
        super.setUp()
        req = .init(assignmentID: "1")
    }
    func testPath() {
        XCTAssertEqual(req.path, "/api/graphql")
    }

    func testBody() {
        req.assertBodyEquals(GraphQLBody(
            query: GetPostPolicyAssignmentSubmissionsRequest.query,
            operationName: "GetPostPolicyAssignmentSubmissionsRequest",
            variables: .init(
                assignmentID: "1"
            )
        ))
    }
}
