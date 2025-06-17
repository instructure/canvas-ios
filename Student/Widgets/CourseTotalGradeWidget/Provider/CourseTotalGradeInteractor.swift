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

import Core
import Combine

class CourseTotalGradeInteractor {
    static let shared = CourseTotalGradeInteractor(env: .shared)

    private var env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()
    private(set) var isLoggedIn: Bool = false

    init(env: AppEnvironment) {
        self.env = env
        self.setup()
    }

    func setup() {
        env.app = .student

        guard let session = LoginSession.mostRecent else { return }
        env.userDidLogin(session: session, isSilent: true)
        isLoggedIn = true
    }

    private var userID: String? {
        env.currentSession?.userID
    }

    func fetchSuggestedCourses() async throws -> [Course] {
        try await withCheckedThrowingContinuation { continuation in
            ReactiveStore(useCase: GetDashboardCourses())
                .getEntities()
                .sinkFailureOrValue { error in
                    continuation.resume(throwing: error)
                } receiveValue: { courses in
                    continuation.resume(returning: courses)
                }
                .store(in: &self.subscriptions)
        }
    }

    func fetchCourses(ofIDs courseIDs: [String]) async -> [Course] {
        var courses = [Course]()
        for courseID in courseIDs {
            if let course = await fetchCourse(withID: courseID) {
                courses.append(course)
            }
        }
        return courses
    }

    func fetchCourse(withID courseID: String) async -> Course? {
        await withCheckedContinuation { continuation in
            ReactiveStore(useCase: GetCourse(courseID: courseID))
                .getEntities()
                .sinkFailureOrValue { _ in
                    continuation.resume(returning: nil)
                } receiveValue: { courses in
                    continuation.resume(returning: courses.first)
                }
                .store(in: &self.subscriptions)
        }
    }

    private var interactor: GradeListInteractor?

    func fetchCourseTotalGrade(courseID: String) async -> CourseTotalGradeData? {
        guard let course = await fetchCourse(withID: courseID) else { return nil }

        let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
        let interactor = GradeListAssembly
            .makeInteractor(environment: self.env, courseID: courseID, userID: self.userID)

        print("fetching total grade for: \(course.name ?? "")")

        return await withCheckedContinuation { continuation in
            interactor
                .getGrades(
                    arrangeBy: .dueDate,
                    baseOnGradedAssignment: true,
                    gradingPeriodID: courseEnrollment?.currentGradingPeriodID,
                    ignoreCache: false
                )
                .map({ listData -> CourseTotalGradeData in
                    guard let courseName = listData.courseName else {
                        return .empty(courseID: courseID)
                    }

                    return CourseTotalGradeData(
                        courseID: courseID,
                        courseName: courseName,
                        courseColor: listData.courseColor?.asColor,
                        grade: listData.totalGradeText.flatMap { .init($0) }
                    )
                })
                .replaceEmpty(with: .empty(courseID: courseID))
                .sinkFailureOrValue { error in

                    print(error)
                    continuation.resume(returning: nil)
                } receiveValue: { gradeData in
                    continuation.resume(returning: gradeData)
                }
                .store(in: &self.subscriptions)
        }
    }
}
