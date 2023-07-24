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

import Combine
import Foundation

public protocol CourseSyncAssignmentsInteractor: CourseSyncContentInteractor {}
public extension CourseSyncAssignmentsInteractor {
    var associatedTabType: TabName { .assignments }
}

public final class CourseSyncAssignmentsInteractorLive: CourseSyncAssignmentsInteractor, CourseSyncContentInteractor {
    public init() {}

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetAssignmentsByGroup(courseID: courseId)
        )
        .getEntities()
        .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
        .filter { $0.submission != nil }
        .flatMap { Self.getSubmissionComments(courseID: courseId, assignmentID: $0.id, userID: $0.submission!.userID) }
        .collect()
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private static func getSubmissionComments(
        courseID: String,
        assignmentID: String,
        userID: String
    ) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetSubmissionComments(
                context: .course(courseID),
                assignmentID: assignmentID,
                userID: userID
            )
        )
        .getEntities()
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}
