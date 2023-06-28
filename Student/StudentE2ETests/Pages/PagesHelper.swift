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
import TestsFoundation
import XCTest

public class PagesHelper: BaseHelper {
    public static func navigateToPages(course: DSCourse) {
        let courseCard = Dashboard.courseCard(id: course.id).waitToExist()
        courseCard.tap()
        let pagesButton = CourseNavigation.pages.waitToExist()
        pagesButton.tap()
    }

    public static func navigateToFrontPage(course: DSCourse) {
        navigateToPages(course: course)
        let frontPage = PageList.frontPage.waitToExist()
        frontPage.tap()
    }

    public static func createLinkToAssignment(course: DSCourse, assignment: DSAssignment) -> String {
        let link = "<p><a title=\"\(assignment.name)\" href=\"https://\(user.host)/courses/\(course.id)/assignments/\(assignment.id)?wrap=1\">\(assignment.name)</a></p>"
        return link
    }

    public static func createLinkToDiscussion(course: DSCourse, discussion: DSDiscussionTopic) -> String {
        let link = "<p><a title=\"\(discussion.title)\" href=\"https://\(user.host)/courses/\(course.id)/discussion_topics/\(discussion.id)?wrap=1\">\(discussion.title)</a></p>"
        return link
    }

    @discardableResult
    public static func createDeepLinkFrontPage(course: DSCourse, body: String) -> DSPage {
        let pageBody = CreateDSPageRequest.RequestDSPage(title: "Deep Link Front Page", body: body, front_page: true, published: true)
        return try! seeder.createPage(courseId: course.id, requestBody: pageBody)
    }
}
