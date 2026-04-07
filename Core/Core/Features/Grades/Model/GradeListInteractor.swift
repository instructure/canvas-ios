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
import Snapshots

public struct GradeListGradingPeriodData {
    let course: CourseSnapshot
    let currentlyActiveGradingPeriodID: String?
    let gradingPeriods: [GradingPeriod.Snapshot]
}

public protocol GradeListInteractor {
    var courseID: String { get }

    func getGrades(
        arrangeBy: GradeArrangementOptions,
        baseOnGradedAssignment: Bool,
        gradingPeriodID: String?,
        ignoreCache: Bool
    ) async throws -> GradeListData

    func loadBaseData(
        ignoreCache: Bool
    ) async throws -> GradeListGradingPeriodData

    func isWhatIfScoreFlagEnabled() -> Bool
}

public final class GradeListInteractorLive: GradeListInteractor {

    // MARK: - Dependencies

    public let courseID: String
    private let userID: String?
    private let filterAssignmentsToUserID: Bool
    private let env: AppEnvironment

    // MARK: - Private properties
    private let customStatusesStore: DetachableAsyncStore<GetCustomGradeStatuses>
    private let colorListStore: DetachableAsyncStore<GetCustomColors>
    private let courseStore: AsyncStore<GetCourse, CourseSnapshot>
    private let gradingPeriodListStore: DetachableAsyncStore<GetGradingPeriods>

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

    public func loadBaseData(ignoreCache: Bool) async throws -> GradeListGradingPeriodData {
        async let customStatuses = customStatusesStore.getEntities(ignoreCache: ignoreCache)
        async let colors = colorListStore.getEntities(ignoreCache: ignoreCache)
        async let course = courseStore.getSingleEntity(ignoreCache: ignoreCache)
        async let gradingPeriods = gradingPeriodListStore.getEntities(ignoreCache: ignoreCache, loadAllPages: true)

        (_, _) = await (try? customStatuses, try colors)

        let courseEnrollment = try await course.enrollmentForGrades(userId: userID, includingCompleted: true)

        return GradeListGradingPeriodData(
            course: try await course,
            currentlyActiveGradingPeriodID: courseEnrollment?.attributes.currentGradingPeriodID,
            gradingPeriods: try await gradingPeriods
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
            returns: EnrollmentSnapshot.self,
            environment: env
        )
        let assignmentListStore = AsyncStore(
            useCase: GetAssignmentsByGroup(
                courseID: courseID,
                gradingPeriodID: gradingPeriodID,
                gradedOnly: true,
                userID: filterAssignmentsToUserID ? userID : nil
            ),
            returns: AssignmentSnapshot.self,
            environment: env
        )

        async let (course, gradingPeriods) = loadCachedCoursesAndGradingPeriods()
        async let assignments = assignmentListStore.getEntities(ignoreCache: ignoreCache, loadAllPages: true)
        async let enrollments = enrollmentListStore.getEntities(ignoreCache: true, loadAllPages: true)

        let courseEnrollment = try await course.enrollmentForGrades(userId: userID, includingCompleted: true)
        let isGradingPeriodHidden = courseEnrollment?.multipleGradingPeriodsEnabled == false

        let assignmentSections: [AssignmentListSection]
        switch arrangeBy {
        case .dueDate:
            assignmentSections = groupAssignmentsByDueDate(try await assignments)
        case .groupName:
            assignmentSections = groupAssignmentsByAssignmentGroups(try await assignments)
        }

        let totalGradeText = calculateTotalGrade(
            course: try await course,
            enrollments: try await enrollments,
            gradingPeriodID: gradingPeriodID,
            baseOnGradedAssignments: baseOnGradedAssignment
        )

        return GradeListData(
            id: UUID.string,
            userID: userID ?? "",
            courseName: try await course.attributes.name,
            courseColor: try await course.attributes.color,
            assignmentSections: assignmentSections,
            isGradingPeriodHidden: isGradingPeriodHidden,
            gradingPeriods: try await gradingPeriods,
            currentGradingPeriod: try await getGradingPeriod(id: gradingPeriodID, gradingPeriods: gradingPeriods),
            totalGradeText: totalGradeText,
            currentGradingPeriodID: courseEnrollment?.attributes.currentGradingPeriodID
        )
    }

    public func isWhatIfScoreFlagEnabled() -> Bool {
        ExperimentalFeature.whatIfScore.isEnabled && AppEnvironment.shared.app == .student
    }

    // MARK: - Private Methods

    private func loadCachedCoursesAndGradingPeriods() async throws -> (CourseSnapshot, [GradingPeriod.Snapshot]) {
        async let course = courseStore.getSingleEntity(ignoreCache: false)
        async let gradingPeriods = gradingPeriodListStore.getEntities(ignoreCache: false, loadAllPages: true)

        return try await (course, gradingPeriods)
    }

    private func getGradingPeriod(id: String?, gradingPeriods: [GradingPeriod.Snapshot]) -> GradingPeriod.Snapshot? {
        guard let id else {
            return nil
        }
        return gradingPeriods.filter { $0.id == id }.first
    }

    private func groupAssignmentsByAssignmentGroups(_ assignments: [AssignmentSnapshot]) -> [AssignmentListSection] {
        let allAssignments = assignments
            .sorted {
                switch ($0.attributes.assignmentGroupPosition, $1.attributes.assignmentGroupPosition) {
                case let (lhsPosition, rhsPosition) where lhsPosition < rhsPosition:
                    true
                case let (lhsPosition, rhsPosition) where lhsPosition == rhsPosition:
                    $0.attributes.dueAtForSorting < $1.attributes.dueAtForSorting
                default:
                    false
                }
            }

        var assignmentsByGroup: [String: [AssignmentSnapshot]] = [:]
        var groupIds: [String] = []
        allAssignments.forEach { assignment in
            let groupId = assignment.attributes.assignmentGroupID ?? ""
            if assignmentsByGroup.keys.contains(groupId) {
                assignmentsByGroup[groupId]?.append(assignment)
            } else {
                assignmentsByGroup[groupId] = [assignment]
                groupIds.append(groupId)
            }
        }

        return groupIds.compactMap { groupId in
            guard let assignments = assignmentsByGroup[groupId] else { fatalError() /*return nil*/ }
            return AssignmentListSection(
                id: groupId,
                title: assignments.first?.assignmentGroup?.name ?? "",
                rows: assignments.map { row(for: $0) }
            )
        }
    }

    private func groupAssignmentsByDueDate(_ assignments: [AssignmentSnapshot]) -> [AssignmentListSection] {
        let allAssignments = assignments
            .sorted {
                $0.attributes.dueAtForSorting < $1.attributes.dueAtForSorting
            }

        var overdueAssignments: [AssignmentSnapshot] = []
        var upcomingAssignments: [AssignmentSnapshot] = []
        var pastAssignments: [AssignmentSnapshot] = []
        let now = Clock.now
        allAssignments.forEach { assignment in
            let dueAt = assignment.attributes.dueAtForSorting
            if let lockAt = assignment.attributes.lockAt {
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

    private func row(for assignment: AssignmentSnapshot) -> AssignmentListSection.Row {
        .gradeListRow(.init(assignment: assignment, userId: userID))
    }

    private func calculateTotalGrade(
        course: CourseSnapshot,
        enrollments: [EnrollmentSnapshot],
        gradingPeriodID: String?,
        baseOnGradedAssignments: Bool
    ) -> String? {
        let courseEnrollment = course.enrollmentForGrades(userId: userID, includingCompleted: true)
        let gradeEnrollment = gradeEnrollment(from: enrollments)
        let hideQuantitativeData = course.attributes.hideQuantitativeData == true

        // When these conditions are met we don't show any grade, instead we display a lock icon.
        if (courseEnrollment?.attributes.multipleGradingPeriodsEnabled == true &&
            courseEnrollment?.attributes.totalsForAllGradingPeriodsOption == false &&
            gradingPeriodID == nil) || course.attributes.hideFinalGrades {
            return nil
        } else if hideQuantitativeData {
            return getGradeForHideQuantitativeData(
                baseOnGradedAssignments: baseOnGradedAssignments,
                courseEnrollment: courseEnrollment,
                gradeEnrollment: gradeEnrollment,
                gradingPeriodID: gradingPeriodID,
                course: course
            )
        } else {
            return getGradeForShowQuantitativeData(
                baseOnGradedAssignments: baseOnGradedAssignments,
                courseEnrollment: courseEnrollment,
                gradeEnrollment: gradeEnrollment,
                gradingPeriodID: gradingPeriodID,
                gradingScheme: course.attributes.gradingScheme
            )
        }
    }

    private func getGradeForHideQuantitativeData(
        baseOnGradedAssignments: Bool,
        courseEnrollment: EnrollmentSnapshot?,
        gradeEnrollment: EnrollmentSnapshot?,
        gradingPeriodID: String?,
        course: CourseSnapshot
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
                    gradingScheme: course.attributes.gradingScheme
                )
            }
        }

        func getGradeForNoGradingPeriod() -> String? {
            let letterGrade = (
                baseOnGradedAssignments
                ? courseEnrollment?.attributes.computedCurrentGrade
                : courseEnrollment?.attributes.computedFinalGrade
            ) ?? courseEnrollment?.attributes.computedCurrentLetterGrade

            if courseEnrollment?.attributes.multipleGradingPeriodsEnabled == true,
               courseEnrollment?.attributes.totalsForAllGradingPeriodsOption == false {
                return nil
            } else if let letterGrade {
                return letterGrade
            } else {
                return courseEnrollment?.convertedLetterGrade(
                    gradingPeriodID: nil,
                    gradingScheme: course.attributes.gradingScheme
                )
            }
        }
    }

    private func getGradeForShowQuantitativeData(
        baseOnGradedAssignments: Bool,
        courseEnrollment: EnrollmentSnapshot?,
        gradeEnrollment: EnrollmentSnapshot?,
        gradingPeriodID: String?,
        gradingScheme: any GradingScheme
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
                    letterGrade = courseEnrollment?.attributes.computedCurrentGrade ?? courseEnrollment?.attributes.computedCurrentLetterGrade
                } else {
                    letterGrade = courseEnrollment?.attributes.computedFinalGrade ?? courseEnrollment?.attributes.computedCurrentLetterGrade
                }
            }
        }
    }

    private func courseEnrollment(_ course: Course, userId: String?) -> Enrollment? {
        course.enrollmentForGrades(userId: userId, includingCompleted: true)
    }

    private func gradeEnrollment(from list: [EnrollmentSnapshot]) -> EnrollmentSnapshot? {
        func first(of state: EnrollmentState) -> EnrollmentSnapshot? {
            list.first {
                let attributes = $0.attributes

                return attributes.id != nil &&
                attributes.state == state &&
                attributes.userID == userID &&
                attributes.type.lowercased().contains("student")
            }
        }
        return first(of: .active) ?? first(of: .completed)
    }
}
