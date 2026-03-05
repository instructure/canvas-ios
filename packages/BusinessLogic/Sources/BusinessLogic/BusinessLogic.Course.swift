//
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

extension BusinessLogic {

    public protocol Course {
        func shouldShowAsInvitedCourse(isCourseClosed: Bool, hasInvitedEnrollment: Bool) -> Bool
    }

    public struct CourseLive: Course, Sendable {

        public init() {}

        public func shouldShowAsInvitedCourse(isCourseClosed: Bool, hasInvitedEnrollment: Bool) -> Bool {
            !isCourseClosed && hasInvitedEnrollment
        }
    }
}

extension BusinessLogic.Course where Self == BusinessLogic.CourseLive {
    public static var live: BusinessLogic.CourseLive { .init() }
}
