//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import TestsFoundation

class DSDiscussionsE2ETests: E2ETestCase {
    func testDiscussionsE2E() {
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        seeder.enrollStudent(student, in: course)

        let discussionTitle = "Discussion Title"
        let discussionMessage = "This is a discussion"
        let discussion = seeder.createDiscussion(courseId: course.id, requestBody: .init(title: discussionTitle, message: discussionMessage, is_announcement: false, published: true))

        logInDSUser(student)
        Dashboard.courseCard(id: course.id).waitToExist()
        Dashboard.courseCard(id: course.id).tap()
        pullToRefresh()
        CourseNavigation.discussions.waitToExist()
        CourseNavigation.discussions.tap()
        DiscussionListCell.cell(id: discussion.id).waitToExist()
    }
}
