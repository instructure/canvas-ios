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

public protocol CourseSyncGradesInteractor: CourseSyncContentInteractor {}

public class CourseSyncGradesInteractorLive: CourseSyncGradesInteractor {
    private typealias CurrentGradingPeriodID = String
    public var associatedTabType: TabName { .grades }

    private let envResolver: CourseSyncEnvironmentResolver
    public init(envResolver: CourseSyncEnvironmentResolver) {
        self.envResolver = envResolver
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        let userId = envResolver.userId
        let env = envResolver.targetEnvironment(for: courseId)

        return Publishers
            .Zip3(
                Self.fetchCourseColors(),
                Self.fetchGradingPeriods(courseId: courseId, env: env),
                Self.fetchCourseAndGetGradingPeriodID(courseId: courseId, userId: userId, env: env)
                    .flatMap { gradingPeriodID in
                        Publishers.Zip(
                            Self.fetchEnrollments(courseId: courseId, userId: userId, gradingPeriodID: gradingPeriodID, env: env),
                            Self.fetchAssignments(courseId: courseId, gradingPeriodID: gradingPeriodID, env: env)
                        )
                    }
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private static func fetchCourseColors() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCustomColors())
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchGradingPeriods(courseId: CourseSyncID, env: AppEnvironment) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetGradingPeriods(courseID: courseId.localID),
            environment: env
        )
        .getEntities(ignoreCache: true)
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private static func fetchCourseAndGetGradingPeriodID(
        courseId: CourseSyncID,
        userId: String,
        env: AppEnvironment
    ) -> AnyPublisher<CurrentGradingPeriodID?, Error> {
        ReactiveStore(
            useCase: GetCourse(courseID: courseId.localID),
            environment: env
        )
        .getEntities(ignoreCache: true)
        .map { $0.first?.enrollmentForGrades(userId: userId)?.currentGradingPeriodID }
        .eraseToAnyPublisher()
    }

    private static func fetchEnrollments(
        courseId: CourseSyncID,
        userId: String,
        gradingPeriodID: String?,
        env: AppEnvironment
    ) -> AnyPublisher<Void, Error> {
        let useCase = GetEnrollments(context: courseId.asContext,
                                     userID: userId,
                                     gradingPeriodID: gradingPeriodID,
                                     types: ["StudentEnrollment"],
                                     states: [.active])
        return ReactiveStore(useCase: useCase, environment: env)
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchAssignments(
        courseId: CourseSyncID,
        gradingPeriodID: String?,
        env: AppEnvironment
    ) -> AnyPublisher<Void, Error> {
        let useCase = GetAssignmentsByGroup(courseID: courseId.localID,
                                            gradingPeriodID: gradingPeriodID,
                                            gradedOnly: true)
        return ReactiveStore(useCase: useCase, environment: env)
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
