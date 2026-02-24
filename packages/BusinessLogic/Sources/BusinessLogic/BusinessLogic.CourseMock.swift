// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

#if DEBUG

extension BusinessLogic {

    public final class CourseMock: Course {

        public var shouldShowAsInvitedCourseReturnValue = false
        public private(set) var shouldShowAsInvitedCourseReceivedInvocations: [(isCourseClosed: Bool, hasInvitedEnrollment: Bool)] = []

        public init(shouldShowAsInvitedCourseReturnValue: Bool = false) {
            self.shouldShowAsInvitedCourseReturnValue = shouldShowAsInvitedCourseReturnValue
        }

        public func shouldShowAsInvitedCourse(isCourseClosed: Bool, hasInvitedEnrollment: Bool) -> Bool {
            shouldShowAsInvitedCourseReceivedInvocations.append((isCourseClosed, hasInvitedEnrollment))
            return shouldShowAsInvitedCourseReturnValue
        }
    }
}

#endif
