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

import Combine
import Foundation

protocol CourseInvitationsInteractor {
    func fetchInvitations(ignoreCache: Bool) -> AnyPublisher<[CourseInvitation], Error>
    func acceptInvitation(id: String) -> AnyPublisher<Void, Error>
    func declineInvitation(id: String) -> AnyPublisher<Void, Error>
}

final class CourseInvitationsInteractorLive: CourseInvitationsInteractor {

    func fetchInvitations(ignoreCache: Bool) -> AnyPublisher<[CourseInvitation], Error> {
        let mockInvitations = [
            CourseInvitation(
                id: "1",
                courseName: "Introduction to Computer Science",
                invitedBy: "Dr. Sarah Johnson",
                invitedAt: Date()
            ),
            CourseInvitation(
                id: "2",
                courseName: "Mathematics 101",
                invitedBy: "Prof. Michael Chen",
                invitedAt: Date().addingTimeInterval(-86400)
            ),
            CourseInvitation(
                id: "3",
                courseName: "World History: Ancient Civilizations",
                invitedBy: "Dr. Emily Rodriguez",
                invitedAt: Date().addingTimeInterval(-172800)
            )
        ]

        return Just(mockInvitations)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func acceptInvitation(id: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func declineInvitation(id: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
