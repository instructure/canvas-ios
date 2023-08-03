//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation

@testable import Core
import XCTest

class CourseSyncDiscussionsInteractorLiveTests: CoreTestCase {
    private var testee: CourseSyncDiscussionsInteractorLive!

    override func setUp() {
        super.setUp()
        testee = CourseSyncDiscussionsInteractorLive()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testSuccess() {
        mockDiscussionTopics()
        mockDiscussionViews()
        XCTAssertFinish(testee.getContent(courseId: "course-1"))
    }

    func testDiscussionTopicsFailure() {
        mockDiscussionTopicsFailure()
        mockDiscussionViews()
        XCTAssertFailure(testee.getContent(courseId: "course-1"))
    }

    func testDiscussionViewsFailure() {
        mockDiscussionTopics()
        mockDiscussionViewsError()
        XCTAssertFailure(testee.getContent(courseId: "course-1"))
    }

    private func mockDiscussionTopics() {
        api.mock(
            GetDiscussionTopics(context: .course("course-1")),
            value: [
                .make(
                    html_url: URL(string: "https://canvas.instructure.com/courses/course-1/discussion_topics"),
                    id: "topic-1"
                ),
            ]
        )
    }

    private func mockDiscussionTopicsFailure() {
        api.mock(
            GetDiscussionTopics(context: .course("course-1")),
            error: NSError.instructureError("")
        )
    }

    private func mockDiscussionViews() {
        api.mock(
            GetDiscussionView(context: .course("course-1"), topicID: "topic-1"),
            value: .make()
        )
    }

    private func mockDiscussionViewsError() {
        api.mock(
            GetDiscussionView(context: .course("course-1"), topicID: "topic-1"),
            error: NSError.instructureError("")
        )
    }
}
