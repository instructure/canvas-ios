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

protocol CourseTotalGradeInteractor {
    var isLoggedIn: Bool { get }
    var domain: String? { get }
    func updateEnvironment()
    func fetchSuggestedCourses() async throws -> [Course]
    func fetchCourses(ofIDs courseIDs: [String]) async -> [Course]
    func fetchCourse(withID courseID: String) async -> Course?
    func fetchCourseTotalGrade(courseID: String, baseOnGradedAssignment: Bool) async -> CourseTotalGradeData
}

class CourseTotalGradeInteractorLive: CourseTotalGradeInteractor {

    private var env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()
    private var userID: String? {
        env.currentSession?.userID
    }

    init(env: AppEnvironment = .shared) {
        self.env = env
    }

    var isLoggedIn: Bool { env.currentSession != nil }
    var domain: String? { env.apiHost }

    func updateEnvironment() {
        // Reset
        env.app = .student

        guard let session = LoginSession.mostRecent else { return }
        if let current = env.currentSession, current == session { return }

        // Update with latest session
        env.userDidLogin(session: session, isSilent: true)
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

    func fetchCourseTotalGrade(courseID: String, baseOnGradedAssignment: Bool) async -> CourseTotalGradeModel.Data {
        guard
            let course = await fetchCourse(withID: courseID),
            let courseName = course.name
        else {
            return .courseNotFound(courseID: courseID)
        }

        let courseAttributes = CourseTotalGradeModel.CourseAttributes(
            name: courseName,
            color: course.color.asColor
        )

        let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
        let interactor = GradeListAssembly
            .makeInteractor(environment: env, courseID: courseID, userID: self.userID)

        return await withCheckedContinuation { continuation in
            interactor
                .getGrades(
                    arrangeBy: .dueDate,
                    baseOnGradedAssignment: baseOnGradedAssignment,
                    gradingPeriodID: courseEnrollment?.currentGradingPeriodID,
                    ignoreCache: false
                )
                .map({ listData -> CourseTotalGradeModel.Data in

                    guard let gradeText = listData.totalGradeText else {
                        return CourseTotalGradeData(courseID: courseID, fetchResult: .restricted(attributes: courseAttributes))
                    }

                    let fetchResult: CourseTotalGradeModel.FetchResult = gradeText.isNotEmpty
                        ? .grade(attributes: courseAttributes, text: gradeText)
                        : .noGrade(attributes: courseAttributes)

                    return CourseTotalGradeData(courseID: courseID, fetchResult: fetchResult)
                })
                .replaceEmpty(
                    with: CourseTotalGradeData(
                        courseID: courseID,
                        fetchResult: .restricted(attributes: courseAttributes)
                    )
                )
                .sinkFailureOrValue { error in
                    continuation.resume(
                        returning: CourseTotalGradeData(
                            courseID: courseID,
                            fetchResult: .failure(attributes: courseAttributes, error: error.localizedDescription)
                        )
                    )
                } receiveValue: { gradeData in
                    continuation.resume(returning: gradeData)
                }
                .store(in: &self.subscriptions)
        }
    }
}

extension CourseTotalGradeModel {
    static var interactor: CourseTotalGradeInteractor = CourseTotalGradeInteractorLive()
}
