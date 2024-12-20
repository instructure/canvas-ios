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

struct DashboardInvitationAPIItem: Equatable {
    let enrollmentId: ID
    let courseId: ID
    let sectionId: ID
}

extension Array where Element == APIEnrollment {

    var invitationAPIItems: [DashboardInvitationAPIItem] {
        compactMap {
            guard $0.enrollment_state == .invited, let enrollmentId = $0.id, let courseId = $0.course_id, let sectionId = $0.course_section_id else { return nil }
            return DashboardInvitationAPIItem(enrollmentId: enrollmentId, courseId: courseId, sectionId: sectionId)
        }
    }
}
