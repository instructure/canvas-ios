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

import Core
import XCTest

class CDWidgetAnnouncementTests: CoreTestCase {

    func testSave() {
        let avatarImageURL = Bundle(for: UIImageExtensionsTests.self).url(forResource: "TestImage",
                                                                         withExtension: "png")!
        let mockDate = Date()
        Clock.mockNow(mockDate)
        _ = ContextColor.make()
        _ = Course.make(in: databaseClient)
        let apiDiscussion = APIDiscussionTopic.make(author: .make(avatar_image_url: avatarImageURL),
                                                    context_code: "course_1",
                                                    html_url: URL(string: "/testdiscussion")!,
                                                    posted_at: mockDate)

        // WHEN
        let testee = CDWidgetAnnouncement.save(apiDiscussion, in: databaseClient)

        // THEN
        guard let testee else { return XCTFail() }
        XCTAssertEqual(testee.id, "1")
        XCTAssertEqual(testee.title, "my discussion topic")
        XCTAssertEqual(testee.date, mockDate)
        XCTAssertEqual(testee.url, URL(string: "/testdiscussion")!)
        XCTAssertEqual(testee.authorName, "Bob")
        XCTAssertNotNil(testee.avatar)
        XCTAssertEqual(testee.courseName, "Course One")
        XCTAssertEqual(testee.courseColor.hexString,
                       UIColor.red.ensureContrast(against: .backgroundLightest).hexString)

        Clock.reset()
    }
}
