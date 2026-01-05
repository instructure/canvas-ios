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
    ) async throws -> GradeListData

    func loadBaseData(ignoreCache: Bool) async throws -> GradeListGradingPeriodData

    func isWhatIfScoreFlagEnabled() -> Bool
}

public final class GradeListInteractorLive: GradeListInteractor {

    // MARK: - Dependencies

    public let courseID: String
    private let userID: String?
    private let filterAssignmentsToUserID: Bool
    private let env: AppEnvironment

    // MARK: - Private properties
    private let customStatusesStore: AsyncStore<GetCustomGradeStatuses>
    private let colorListStore: AsyncStore<GetCustomColors>
    private let courseStore: AsyncStore<GetCourse>
    private let gradingPeriodListStore: AsyncStore<GetGradingPeriods>

    // MARK: - Init

    /// - parameters:
    ///   - filterAssignmentsToUserID: If true, the assignments will be filtered to the userID. This is used for parent accounts where the assignments API call returns all students' assignments.
    public init(
        env: AppEnvironment,
        courseID: String,
        userID: String?,
        filterAssignmentsToUserID: Bool? = nil
    ) {
        self.env = env
        self.courseID = courseID
        self.userID = userID
        self.filterAssignmentsToUserID = filterAssignmentsToUserID ?? (env.app == .parent)

        customStatusesStore = AsyncStore(
            useCase: GetCustomGradeStatuses(courseID: courseID),
            environment: env
        )

        colorListStore = AsyncStore(
            useCase: GetCustomColors(),
            environment: env
        )

        courseStore = AsyncStore(
            useCase: GetCourse(courseID: courseID),
            environment: env
        )

        gradingPeriodListStore = AsyncStore(
            useCase: GetGradingPeriods(courseID: courseID),
            environment: env
        )
    }

    public enum GradeListInteractorError: Error {
        case courseNotFound
    }

    public func loadBaseData(ignoreCache: Bool) async throws -> GradeListGradingPeriodData {
        async let customStatuses = customStatusesStore.getEntities(ignoreCache: ignoreCache)
        async let colors = colorListStore.getEntities(ignoreCache: ignoreCache).first
        async let course = courseStore.getEntities(ignoreCache: ignoreCache).first
        async let gradingPeriods = gradingPeriodListStore.getEntities(ignoreCache: ignoreCache, loadAllPages: true)

        _ = await (try? customStatuses, try colors)
        guard let course = try await course else { throw GradeListInteractorError.courseNotFound }

        let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
        return try await GradeListGradingPeriodData(
            course: course,
            currentlyActiveGradingPeriodID: courseEnrollment?.currentGradingPeriodID,
            gradingPeriods: gradingPeriods
        )
    }

    public func getGrades(
        arrangeBy: GradeArrangementOptions,
        baseOnGradedAssignment: Bool,
        gradingPeriodID: String?,
        ignoreCache: Bool
    ) async throws -> GradeListData {
        let enrollmentListStore = AsyncStore(
            useCase: GetEnrollments(
                context: .course(courseID),
                userID: userID,
                gradingPeriodID: gradingPeriodID,
                types: ["StudentEnrollment", "StudentViewEnrollment"],
                states: [.active, .completed]
            ),
            environment: env
        )
        let assignmentListStore = AsyncStore(
            useCase: GetAssignmentsByGroup(
                courseID: courseID,
                gradingPeriodID: gradingPeriodID,
                gradedOnly: true,
                userID: filterAssignmentsToUserID ? userID : nil
            ),
            environment: env
        )

        async let (course, gradingPeriods) = loadCachedCoursesAndGradingPeriods()
        async let assignments = assignmentListStore.getEntities(ignoreCache: ignoreCache, loadAllPages: true)
        async let enrollments = enrollmentListStore.getEntities(ignoreCache: true, loadAllPages: true)

        let courseEnrollment = try await course.enrollmentForGrades(userId: userID, includingCompleted: true)
        let isGradingPeriodHidden = courseEnrollment?.multipleGradingPeriodsEnabled == false
        let assignmentSections = switch arrangeBy {
        case .dueDate:
            groupAssignmentsByDueDate(try await assignments)
        case .groupName:
            groupAssignmentsByAssignmentGroups(try await assignments)
        }

        let totalGradeText = try await calculateTotalGrade(
            course: course,
            enrollments: enrollments,
            gradingPeriodID: gradingPeriodID,
            baseOnGradedAssignments: baseOnGradedAssignment
        )

        return try await GradeListData(
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
        )
    }

    public func isWhatIfScoreFlagEnabled() -> Bool {
        ExperimentalFeature.whatIfScore.isEnabled && AppEnvironment.shared.app == .student
    }

    // MARK: - Private Methods

    private func loadCachedCoursesAndGradingPeriods() async throws -> (Course, [GradingPeriod]) {
        async let course = courseStore.getEntities(ignoreCache: false).first
        async let gradingPeriods = gradingPeriodListStore.getEntities(ignoreCache: false, loadAllPages: true)
        guard let course = try await course else { throw GradeListInteractorError.courseNotFound }

        return (course, try await gradingPeriods)
    }

    private func getGradingPeriod(id: String?, gradingPeriods: [GradingPeriod]) -> GradingPeriod? {
        guard let id else {
            return nil
        }
        return gradingPeriods.filter { $0.id == id }.first
    }

    private func groupAssignmentsByAssignmentGroups(_ assignments: [Assignment]) -> [AssignmentListSection] {
        let allAssignments = assignments
            .sorted {
                switch ($0.assignmentGroupPosition, $1.assignmentGroupPosition) {
                case let (lhsPosition, rhsPosition) where lhsPosition < rhsPosition:
                    true
                case let (lhsPosition, rhsPosition) where lhsPosition == rhsPosition:
                    $0.dueAtForSorting < $1.dueAtForSorting
                default:
                    false
                }
            }

        var assignmentsByGroup: [String: [Assignment]] = [:]
        var groupIds: [String] = []
        allAssignments.forEach { assignment in
            let groupId = assignment.assignmentGroupID ?? ""
            if assignmentsByGroup.keys.contains(groupId) {
                assignmentsByGroup[groupId]?.append(assignment)
            } else {
                assignmentsByGroup[groupId] = [assignment]
                groupIds.append(groupId)
            }
        }

        return groupIds.compactMap { groupId in
            guard let assignments = assignmentsByGroup[groupId] else { return nil }
            return AssignmentListSection(
                id: groupId,
                title: assignments.first?.assignmentGroup?.name ?? "",
                rows: assignments.map { row(for: $0) }
            )
        }
    }

    private func groupAssignmentsByDueDate(_ assignments: [Assignment]) -> [AssignmentListSection] {
        let allAssignments = assignments
            .sorted {
                $0.dueAtForSorting < $1.dueAtForSorting
            }

        var overdueAssignments: [Assignment] = []
        var upcomingAssignments: [Assignment] = []
        var pastAssignments: [Assignment] = []
        let now = Clock.now
        allAssignments.forEach { assignment in
            let dueAt = assignment.dueAtForSorting
            if let lockAt = assignment.lockAt {
                if lockAt >= now, dueAt <= now {
                    overdueAssignments.append(assignment)
                } else if lockAt > now, dueAt > now {
                    upcomingAssignments.append(assignment)
                } else {
                    pastAssignments.append(assignment)
                }
            } else if dueAt <= now {
                overdueAssignments.append(assignment)
            } else if dueAt > now {
                upcomingAssignments.append(assignment)
            }
        }

        var sections: [AssignmentListSection] = []
        if overdueAssignments.isNotEmpty {
            sections.append(.init(
                id: "overdueAssignments",
                title: String(localized: "Overdue Assignments", bundle: .core),
                rows: overdueAssignments.map { row(for: $0) }
            ))
        }
        if upcomingAssignments.isNotEmpty {
            sections.append(.init(
                id: "upcomingAssignments",
                title: String(localized: "Upcoming Assignments", bundle: .core),
                rows: upcomingAssignments.map { row(for: $0) }
            ))
        }
        if pastAssignments.isNotEmpty {
            sections.append(.init(
                id: "pastAssignments",
                title: String(localized: "Past Assignments", bundle: .core),
                rows: pastAssignments.map { row(for: $0) }
            ))
        }

        return sections
    }

    private func row(for assignment: Assignment) -> AssignmentListSection.Row {
        .gradeListRow(.init(assignment: assignment, userId: userID))
    }

    private func calculateTotalGrade(
        course: Course,
        enrollments: [Enrollment],
        gradingPeriodID: String?,
        baseOnGradedAssignments: Bool
    ) -> String? {
        let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
        let gradeEnrollment = gradeEnrollment(from: enrollments)
        let hideQuantitativeData = course.hideQuantitativeData == true

        // When these conditions are met we don't show any grade, instead we display a lock icon.
        return if (courseEnrollment?.multipleGradingPeriodsEnabled == true &&
            courseEnrollment?.totalsForAllGradingPeriodsOption == false &&
            gradingPeriodID == nil) || course.hideFinalGrades {
            nil
        } else if hideQuantitativeData {
            getGradeForHideQuantitativeData(
                baseOnGradedAssignments: baseOnGradedAssignments,
                courseEnrollment: courseEnrollment,
                gradeEnrollment: gradeEnrollment,
                gradingPeriodID: gradingPeriodID,
                course: course
            )
        } else {
            getGradeForShowQuantitativeData(
                baseOnGradedAssignments: baseOnGradedAssignments,
                courseEnrollment: courseEnrollment,
                gradeEnrollment: gradeEnrollment,
                gradingPeriodID: gradingPeriodID,
                gradingScheme: course.gradingScheme
            )
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
