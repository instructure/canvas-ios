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

public class PagesHelper: BaseHelper {
    public static var frontPage: XCUIElement { app.find(id: "PageList.frontPage") }
    public static var frontPageHeading: XCUIElement { app.find(id: "PageList.frontPageHeading") }
    public static var frontPageTitle: XCUIElement { app.find(id: "PageList.frontPageTitle") }
    public static var emptyPage: XCUIElement { app.find(label: "No Pages") }
    public static var add: XCUIElement { app.find(id: "PageList.add") }

    public static func page(index: Int) -> XCUIElement { return app.find(id: "PageList.\(index)") }

    public struct Editor {
        public static var done: XCUIElement { app.find(id: "PageEditor.doneButton") }
        public static var title: XCUIElement { app.find(id: "PageEditor.titleField") }
        public static var published: XCUIElement { app.find(id: "PageEditor.publishedToggle") }
        public static var frontPage: XCUIElement { app.find(id: "PageEditor.frontPageToggle") }
        public static var editors: XCUIElement { app.find(id: "PageEditor.editorsButton") }
    }

    public struct Details {
        public static var options: XCUIElement { app.find(id: "PageDetails.options") }
    }

    public static func navigateToPages(course: DSCourse) {
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.cell(type: .pages).hit()
    }

    public static func navigateToFrontPage(course: DSCourse) {
        navigateToPages(course: course)
        frontPage.hit()
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
    public static func createPage(course: DSCourse,
                                  title: String = "Sample Page",
                                  body: String = "This is the body of Sample Page",
                                  frontPage: Bool = false,
                                  published: Bool = true) -> DSPage {
        let pageBody = CreateDSPageRequest.RequestedDSPage(title: title, body: body, front_page: frontPage, published: published)
        return seeder.createPage(courseId: course.id, requestBody: pageBody)
    }

    @discardableResult
    public static func createDeepLinkFrontPage(course: DSCourse, body: String) -> DSPage {
        return createPage(course: course, title: "Deep Link Front Page", body: body, frontPage: true, published: true)
    }
}
