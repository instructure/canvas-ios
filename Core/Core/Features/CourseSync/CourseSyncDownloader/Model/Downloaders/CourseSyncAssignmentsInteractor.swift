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

public final class CourseSyncAssignmentsInteractorLive: CourseSyncAssignmentsInteractor, CourseSyncHtmlContentInteractor {
    public let htmlParser: HTMLParser
    public init(htmlParser: HTMLParser) {
        self.htmlParser = htmlParser
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetAssignmentsByGroup(courseID: courseId.localID),
            environment: targetEnvironment(for: courseId)
        )
        .getEntities(ignoreCache: true)
        .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
        .filter { $0.submission != nil }
        .flatMap {[htmlParser] in
            Self.getSubmissionComments(courseID: courseId, assignmentID: $0.id, userID: $0.submission!.userID, htmlParser: htmlParser) }
        .collect()
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private static func getSubmissionComments(
        courseID: CourseSyncID,
        assignmentID: String,
        userID: String,
        htmlParser: HTMLParser
    ) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetSubmissionComments(
                context: courseID.asContext,
                assignmentID: assignmentID,
                userID: userID
            ),
            environment: htmlParser.envResolver.targetEnvironment(for: courseID)
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.comment, id: \.id, courseId: courseID, htmlParser: htmlParser)
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}
