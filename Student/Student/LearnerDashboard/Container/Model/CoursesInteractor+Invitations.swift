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

import Combine
import Core
import Foundation

extension CoursesInteractorLive {

    func acceptInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error> {
        handleInvitation(courseId: courseId, enrollmentId: enrollmentId, isAccepted: true)
    }

    func declineInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error> {
        handleInvitation(courseId: courseId, enrollmentId: enrollmentId, isAccepted: false)
    }

    private func handleInvitation(courseId: String, enrollmentId: String, isAccepted: Bool) -> AnyPublisher<Void, Error> {
        let request = HandleCourseInvitationRequest(
            courseID: courseId,
            enrollmentID: enrollmentId,
            isAccepted: isAccepted
        )

        return env.api.makeRequest(request)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
