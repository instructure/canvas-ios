//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import XCTest

class BulkPublishLocalStateRefresherTests: CoreTestCase {

    func testLocalStateRefresh() {
        // MARK: Save items for module items all published
        let assignment = Assignment.save(.make(id: "a1", published: true),
                                         in: databaseClient,
                                         updateSubmission: false,
                                         updateScoreStatistics: false)
        let discussion = DiscussionTopic.save(.make(id: "d1", published: true),
                                              in: databaseClient)
        let page = Page.save(.make(page_id: "p1", published: true),
                             in: databaseClient)
        let quiz = Quiz.save(.make(id: "q1", published: true),
                             in: databaseClient)
        quiz.courseID = "c1"
        let file = File.save(.make(id: "f1", locked: false, hidden: false),
                             in: databaseClient)
        try! databaseClient.save()

        // MARK: Mock API response to make all items unpublished
        api.mock(GetModulesRequest(courseID: "c1"),
                 value: [
                    .make(id: "m1")
                 ])
        api.mock(
            GetModuleItemsRequest(
                courseID: "c1",
                moduleID: "m1",
                include: [
                    .content_details,
                    .mastery_paths
                ]
            ),
            value: [
                .make(id: "mi1", content: .assignment("a1"), published: false),
                .make(id: "mi2", content: .discussion("d1"), published: false),
                .make(id: "mi3", content: .page("p1"), published: false),
                .make(id: "mi4", content: .quiz("q1"), published: false),
                .make(id: "mi5", content: .file("f1"), published: false)
            ]
        )
        api.mock(
            GetFileRequest(
                context: .course("c1"),
                fileID: "f1",
                include: []
            ),
            value: .make(id: "f1", hidden: true)
        )

        let testee = BulkPublishLocalStateRefresherLive(
            courseId: "c1",
            moduleIds: ["m1"],
            action: .unpublish(.modulesAndItems)
        )
        XCTAssertTrue(assignment.published)
        XCTAssertTrue(discussion.published)
        XCTAssertTrue(page.published)
        XCTAssertTrue(quiz.published)
        XCTAssertTrue(file.availability == .published)

        // MARK: WHEN
        XCTAssertFinish(testee.refreshStates())

        // MARK: THEN
        XCTAssertFalse(assignment.published)
        XCTAssertFalse(discussion.published)
        XCTAssertFalse(page.published)
        XCTAssertFalse(quiz.published)
        XCTAssertFalse(file.availability == .published)
    }
}
