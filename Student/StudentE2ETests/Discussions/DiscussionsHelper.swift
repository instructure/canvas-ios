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
import Core
import TestsFoundation
import XCTest

public class DiscussionsHelper: BaseHelper {
    public static func discussionDetailsNavBar(course: DSCourse) -> Element {
        app.find(id: "Discussion Details, \(course.name)")
    }

    @discardableResult
    public static func createDiscussion(
        course: DSCourse,
        title: String = "Sample Discussion",
        message: String = "Message of ",
        isAnnouncement: Bool = false,
        published: Bool = true) -> DSDiscussionTopic {
        let discussionBody = CreateDSDiscussionRequest.RequestDSDiscussion(title: title, message: message, is_announcement: isAnnouncement, published: published)
            return seeder.createDiscussion(courseId: course.id, requestBody: discussionBody)
    }
}
