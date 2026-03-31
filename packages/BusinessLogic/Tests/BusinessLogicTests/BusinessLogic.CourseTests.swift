//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Testing
@testable import BusinessLogic

struct BusinessLogicCourseTests {
    private let testee = BusinessLogic.CourseLive()

    @Test
    func shouldShowAsInvitedCourse() {
        #expect(testee.shouldShowAsInvitedCourse(isCourseClosed: false, hasInvitedEnrollment: true))
        #expect(!testee.shouldShowAsInvitedCourse(isCourseClosed: true, hasInvitedEnrollment: true))
        #expect(!testee.shouldShowAsInvitedCourse(isCourseClosed: false, hasInvitedEnrollment: false))
        #expect(!testee.shouldShowAsInvitedCourse(isCourseClosed: true, hasInvitedEnrollment: false))
    }
}
