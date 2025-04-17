//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import CombineExt
import CombineSchedulers
import Foundation

public struct GradeListGradingPeriodData {
    let course: Course
    let currentlyActiveGradingPeriodID: String?
    let gradingPeriods: [GradingPeriod]
}

public protocol GradeListInteractor {
    var courseID: String { get }

    func getGrades(
        arrangeBy: GradeArrangementOptions,
        baseOnGradedAssignment: Bool,
        gradingPeriodID: String?,
        ignoreCache: Bool
    ) -> AnyPublisher<GradeListData, Error>

    func loadBaseData(
        ignoreCache: Bool
    ) -> AnyPublisher<GradeListGradingPeriodData, Error>

    func isWhatIfScoreFlagEnabled() -> Bool
}

public final class GradeListInteractorLive: GradeListInteractor {

    // MARK: - Dependencies

    public let courseID: String
    private let userID: String?
    private let filterAssignmentsToUserID: Bool

    // MARK: - Private properties
    private let colorListStore: ReactiveStore<GetCustomColors>
    private let courseStore: ReactiveStore<GetCourse>
    private let gradingPeriodListStore: ReactiveStore<GetGradingPeriods>

    // MARK: - Init

    /// - parameters:
    ///   - filterAssignmentsToUserID: If true, the assignments will be filtered to the userID. This is used for parent accounts where the assignments API call returns all students' assignments.
    public init(
        courseID: String,
        userID: String?,
        filterAssignmentsToUserID: Bool = (AppEnvironment.shared.app == .parent)
    ) {
        self.courseID = courseID
        self.userID = userID
        self.filterAssignmentsToUserID = filterAssignmentsToUserID

        colorListStore = ReactiveStore(
            useCase: GetCustomColors()
        )

        courseStore = ReactiveStore(
            useCase: GetCourse(courseID: courseID)
        )

        gradingPeriodListStore = ReactiveStore(
            useCase: GetGradingPeriods(courseID: courseID)
        )
    }

    public func loadBaseData(ignoreCache: Bool) -> AnyPublisher<GradeListGradingPeriodData, Error> {
        let userID = userID
        return Publishers.Zip3(
            colorListStore.getEntities(
                ignoreCache: ignoreCache
            ),
            courseStore.getEntities(
                ignoreCache: ignoreCache
            ).compactMap { $0.first },
            fetchGradingPeriods(ignoreCache: ignoreCache)
        )
        .map { (_, course, gradingPeriods) in
            let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
            return GradeListGradingPeriodData(
                course: course,
                currentlyActiveGradingPeriodID: courseEnrollment?.currentGradingPeriodID,
                gradingPeriods: gradingPeriods
            )
        }
        .eraseToAnyPublisher()
    }

    public func getGrades(
        arrangeBy: GradeArrangementOptions,
        baseOnGradedAssignment: Bool,
        gradingPeriodID: String?,
        ignoreCache: Bool
    ) -> AnyPublisher<GradeListData, Error> {
        let enrollmentListStore = ReactiveStore(
            useCase: GetEnrollments(
                context: .course(courseID),
                userID: userID,
                gradingPeriodID: gradingPeriodID,
                types: ["StudentEnrollment"],
                states: [.active, .completed]
            )
        )
        let assignmentListStore = ReactiveStore(
            useCase: GetAssignmentsByGroup(
                courseID: courseID,
                gradingPeriodID: gradingPeriodID,
                gradedOnly: true,
                userID: filterAssignmentsToUserID ? userID : nil
            )
        )

        return Publishers.Zip3(
            loadCachedCoursesAndGradingPeriods(),
            assignmentListStore.getEntities(
                ignoreCache: ignoreCache,
                loadAllPages: true
            ),
            enrollmentListStore.getEntities(
                ignoreCache: ignoreCache,
                loadAllPages: true
            )
        )
        .flatMap { [weak self] (courseAndGradingPeriods, assignments, enrollments) -> AnyPublisher<GradeListData, Error> in
            guard let self else {
                return Empty(completeImmediately: true)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            let course = courseAndGradingPeriods.0
            let gradingPeriods = courseAndGradingPeriods.1
            let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
            let isGradingPeriodHidden = courseEnrollment?.multipleGradingPeriodsEnabled == false
            let assignmentSections: [GradeListData.AssignmentSections]

            switch arrangeBy {
            case .dueDate:
                assignmentSections = arrangeAssignmentsByDueDate(
                    assignments: assignments
                )
            case .groupName:
                assignmentSections = arrangeAssignmentsByGroupNames(
                    assignments: assignments
                )
            }

            return calculateTotalGrade(
                course: course,
                enrollments: enrollments,
                gradingPeriodID: gradingPeriodID,
                baseOnGradedAssignments: baseOnGradedAssignment
            )
            .flatMap { [weak self] totalGradeText -> AnyPublisher<GradeListData, Error> in
                guard let self = self else {
                    return Empty(completeImmediately: true)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Just(GradeListData(
                    id: UUID.string,
                    userID: userID ?? "",
                    courseName: course.name,
                    courseColor: course.color,
                    assignmentSections: assignmentSections,
                    isGradingPeriodHidden: isGradingPeriodHidden,
                    gradingPeriods: gradingPeriods,
                    currentGradingPeriod: getGradingPeriod(id: gradingPeriodID, gradingPeriods: gradingPeriods),
                    totalGradeText: totalGradeText,
                    currentGradingPeriodID: courseEnrollment?.currentGradingPeriodID
                ))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    public func isWhatIfScoreFlagEnabled() -> Bool {
        ExperimentalFeature.whatIfScore.isEnabled && AppEnvironment.shared.app == .student
    }

    // MARK: - Private Methods

    private func loadCachedCoursesAndGradingPeriods() -> AnyPublisher<(Course, [GradingPeriod]), Error> {
        Publishers.Zip(
            courseStore.getEntities(
                ignoreCache: false
            ).compactMap { $0.first },
            fetchGradingPeriods(ignoreCache: false)
        )
        .eraseToAnyPublisher()
    }

    private func fetchGradingPeriods(ignoreCache: Bool) -> AnyPublisher<[GradingPeriod], Error> {
        gradingPeriodListStore.getEntities(
            ignoreCache: ignoreCache,
            loadAllPages: true
        )
        .filterMany {
            guard let startDate = $0.startDate else {
                return true
            }

            return Clock.now > startDate
        }
    }

    private func getGradingPeriod(id: String?, gradingPeriods: [GradingPeriod]) -> GradingPeriod? {
        guard let id else {
            return nil
        }
        return gradingPeriods.filter { $0.id == id }.first
    }

    private func arrangeAssignmentsByGroupNames(
        assignments: [Assignment]
    ) -> [GradeListData.AssignmentSections] {
        let orderedAssignments = assignments.sorted {
            $0.dueAtSortNilsAtBottom ?? Date.distantFuture < $1.dueAtSortNilsAtBottom ?? Date.distantFuture
        }
        var assignmentSections: [GradeListData.AssignmentSections] = []
        orderedAssignments.forEach { assignment in
            if let index = assignmentSections.firstIndex(where: { section in
                section.id == assignment.assignmentGroupID ?? ""
            }) {
                assignmentSections[index].assignments.append(assignment)
            } else {
                assignmentSections.append(
                    GradeListData.AssignmentSections(
                        id: assignment.assignmentGroupID ?? UUID.string,
                        title: assignment.assignmentGroupSectionName ?? "",
                        assignments: [assignment]
                    )
                )
            }
        }
        return assignmentSections
    }

    private func arrangeAssignmentsByDueDate(
        assignments: [Assignment]
    ) -> [GradeListData.AssignmentSections] {
        let orderedAssignments = assignments.sorted {
            $0.dueAtSortNilsAtBottom ?? Date.distantFuture < $1.dueAtSortNilsAtBottom ?? Date.distantFuture
        }

        var assignmentSections: [GradeListData.AssignmentSections] = []
        var overdueAssignments = GradeListData.AssignmentSections(
            id: "overdueAssignments",
            title: String(localized: "Overdue Assignments", bundle: .core),
            assignments: []
        )
        var upcomingAssignments = GradeListData.AssignmentSections(
            id: "upcomingAssignments",
            title: String(localized: "Upcoming Assignments", bundle: .core),
            assignments: []
        )
        var pastAssignments = GradeListData.AssignmentSections(
            id: "pastAssignments",
            title: String(localized: "Past Assignments", bundle: .core),
            assignments: []
        )

        let now = Clock.now

        orderedAssignments.forEach { assignment in
            if let dueAt = assignment.dueAtSortNilsAtBottom {
                if let lockAt = assignment.lockAt {
                    if lockAt >= now, dueAt <= now {
                        overdueAssignments.assignments.append(assignment)
                    } else if lockAt > now, dueAt > now {
                        upcomingAssignments.assignments.append(assignment)
                    } else {
                        pastAssignments.assignments.append(assignment)
                    }
                } else if dueAt <= now {
                    overdueAssignments.assignments.append(assignment)
                } else if dueAt > now {
                    upcomingAssignments.assignments.append(assignment)
                }
            } else {
                upcomingAssignments.assignments.append(assignment)
            }
        }

        if !overdueAssignments.assignments.isEmpty {
            assignmentSections.append(overdueAssignments)
        }

        if !upcomingAssignments.assignments.isEmpty {
            assignmentSections.append(upcomingAssignments)
        }

        if !pastAssignments.assignments.isEmpty {
            assignmentSections.append(pastAssignments)
        }
        return assignmentSections
    }

    private func calculateTotalGrade(
        course: Course,
        enrollments: [Enrollment],
        gradingPeriodID: String?,
        baseOnGradedAssignments: Bool
    ) -> AnyPublisher<String?, Never> {
        let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
        let gradeEnrollment = gradeEnrollment(from: enrollments)
        let hideQuantitativeData = course.hideQuantitativeData == true

        // When these conditions are met we don't show any grade, instead we display a lock icon.
        if (courseEnrollment?.multipleGradingPeriodsEnabled == true &&
            courseEnrollment?.totalsForAllGradingPeriodsOption == false &&
            gradingPeriodID == nil) || course.hideFinalGrades {
            return Just(nil).eraseToAnyPublisher()
        } else if hideQuantitativeData {
            return Just(getGradeForHideQuantitativeData(
                baseOnGradedAssignments: baseOnGradedAssignments,
                courseEnrollment: courseEnrollment,
                gradeEnrollment: gradeEnrollment,
                gradingPeriodID: gradingPeriodID,
                course: course
            ))
            .eraseToAnyPublisher()
        } else {
            return Just(getGradeForShowQuantitativeData(
                baseOnGradedAssignments: baseOnGradedAssignments,
                courseEnrollment: courseEnrollment,
                gradeEnrollment: gradeEnrollment,
                gradingPeriodID: gradingPeriodID,
                gradingScheme: course.gradingScheme
            ))
            .eraseToAnyPublisher()
        }
    }

    private func getGradeForHideQuantitativeData(
        baseOnGradedAssignments: Bool,
        courseEnrollment: Enrollment?,
        gradeEnrollment: Enrollment?,
        gradingPeriodID: String?,
        course: Course
    ) -> String? {
        if let gradingPeriodID {
            return getGradeForGradingPeriod(gradingPeriodID: gradingPeriodID)
        } else {
            return getGradeForNoGradingPeriod()
        }

        func getGradeForGradingPeriod(gradingPeriodID: String) -> String? {
            let letterGrade = baseOnGradedAssignments
                ? gradeEnrollment?.currentGrade(gradingPeriodID: gradingPeriodID)
                : gradeEnrollment?.finalGrade(gradingPeriodID: gradingPeriodID)

            if let letterGrade {
                return letterGrade
            } else {
                return gradeEnrollment?.convertedLetterGrade(
                    gradingPeriodID: gradingPeriodID,
                    gradingScheme: course.gradingScheme
                )
            }
        }

        func getGradeForNoGradingPeriod() -> String? {
            let letterGrade = (
                baseOnGradedAssignments
                ? courseEnrollment?.computedCurrentGrade
                : courseEnrollment?.computedFinalGrade
            ) ?? courseEnrollment?.computedCurrentLetterGrade

            if courseEnrollment?.multipleGradingPeriodsEnabled == true,
               courseEnrollment?.totalsForAllGradingPeriodsOption == false {
                return nil
            } else if let letterGrade {
                return letterGrade
            } else {
                return courseEnrollment?.convertedLetterGrade(
                    gradingPeriodID: nil,
                    gradingScheme: course.gradingScheme
                )
            }
        }
    }

    private func getGradeForShowQuantitativeData(
        baseOnGradedAssignments: Bool,
        courseEnrollment: Enrollment?,
        gradeEnrollment: Enrollment?,
        gradingPeriodID: String?,
        gradingScheme: GradingScheme
    ) -> String? {
        var letterGrade: String?
        var localGrade: String?
        if let gradingPeriodID {
            getGradeForGradingPeriod(gradingPeriodID: gradingPeriodID)
        } else {
            getGradeForNoGradingPeriod()
        }

        if let scoreText = localGrade, let letterGrade {
            return scoreText + " (\(letterGrade))"
        } else {
            return localGrade
        }

        func getGradeForGradingPeriod(gradingPeriodID: String) {
            if baseOnGradedAssignments {
                localGrade = gradeEnrollment?.formattedCurrentScore(gradingPeriodID: gradingPeriodID, gradingScheme: gradingScheme)
                letterGrade = gradeEnrollment?.currentGrade(gradingPeriodID: gradingPeriodID)
            } else {
                localGrade = gradeEnrollment?.formattedFinalScore(gradingPeriodID: gradingPeriodID, gradingScheme: gradingScheme)
                letterGrade = gradeEnrollment?.finalGrade(gradingPeriodID: gradingPeriodID)
            }
        }

        func getGradeForNoGradingPeriod() {
            if baseOnGradedAssignments {
                localGrade = gradeEnrollment?.formattedCurrentScore(gradingPeriodID: nil, gradingScheme: gradingScheme)
            } else {
                localGrade = gradeEnrollment?.formattedFinalScore(gradingPeriodID: nil, gradingScheme: gradingScheme)
            }
            if courseEnrollment?.multipleGradingPeriodsEnabled == true, courseEnrollment?.totalsForAllGradingPeriodsOption == false {
                letterGrade = nil
            } else {
                if baseOnGradedAssignments {
                    letterGrade = courseEnrollment?.computedCurrentGrade ?? courseEnrollment?.computedCurrentLetterGrade
                } else {
                    letterGrade = courseEnrollment?.computedFinalGrade ?? courseEnrollment?.computedCurrentLetterGrade
                }
            }
        }
    }

    private func courseEnrollment(_ course: Course, userId: String?) -> Enrollment? {
        course.enrollmentForGrades(userId: userId, includingCompleted: true)
    }

    private func gradeEnrollment(from list: [Enrollment]) -> Enrollment? {
        func first(of state: EnrollmentState) -> Enrollment? {
            return list.first(where: {
                $0.id != nil &&
                $0.state == state &&
                $0.userID == userID &&
                $0.type.lowercased().contains("student")
            })
        }
        return first(of: .active) ?? first(of: .completed)
    }
}
