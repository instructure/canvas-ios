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
import Foundation

public protocol GradeListInteractor {
    var courseID: String { get }
    func getGrades(arrangeBy: GradeArrangementOptions, ignoreCache: Bool) -> AnyPublisher<GradeListData, Error>
    func updateGradingPeriod(id: String?)
}

public final class GradeListInteractorLive: GradeListInteractor {
    // MARK: - Dependencies

    public let courseID: String
    private let userID: String?

    // MARK: - Private properties

    private var assignmentListStore: ReactiveStore<GetAssignmentsByGroup>
    private let colorListStore: ReactiveStore<GetCustomColors>
    private let courseStore: ReactiveStore<GetCourse>
    private var enrollmentListStore: ReactiveStore<GetEnrollments>
    private let gradingPeriodListStore: ReactiveStore<GetGradingPeriods>
    private var gradingPeriodID: String?
    private var isInitialGradingPeriodSet = false

    // MARK: - Init

    public init(
        courseID: String,
        userID: String?
    ) {
        self.courseID = courseID
        self.userID = userID

        assignmentListStore = ReactiveStore(
            useCase: GetAssignmentsByGroup(
                courseID: courseID,
                gradingPeriodID: nil,
                gradedOnly: true
            )
        )

        colorListStore = ReactiveStore(
            useCase: GetCustomColors()
        )

        courseStore = ReactiveStore(
            useCase: GetCourse(courseID: courseID)
        )

        enrollmentListStore = ReactiveStore(
            useCase: GetEnrollments(
                context: .course(courseID),
                userID: userID,
                gradingPeriodID: nil,
                types: ["StudentEnrollment"],
                states: [.active]
            )
        )

        gradingPeriodListStore = ReactiveStore(
            useCase: GetGradingPeriods(courseID: courseID)
        )
    }

    public func getGrades(arrangeBy: GradeArrangementOptions, ignoreCache: Bool) -> AnyPublisher<GradeListData, Error> {
        Publishers.Zip3(
            colorListStore.getEntities(
                ignoreCache: ignoreCache
            ),
            courseStore.getEntities(
                ignoreCache: ignoreCache
            ).compactMap { $0.first },
            gradingPeriodListStore.getEntities(
                ignoreCache: ignoreCache,
                loadAllPages: true
            )
        )
        .zip(
            assignmentListStore.getEntities(
                ignoreCache: ignoreCache,
                loadAllPages: true
            ),
            enrollmentListStore.getEntities(
                ignoreCache: ignoreCache,
                loadAllPages: true
            )
        )
        .flatMap { [unowned self] in
            let course = $0.0.1
            let gradingPeriods = $0.0.2
            let enrollments = $0.2
            let courseEnrollment = course.enrollmentForGrades(userId: userID)
            let isGradingPeriodHidden = courseEnrollment?.multipleGradingPeriodsEnabled == false

            if !isInitialGradingPeriodSet {
                isInitialGradingPeriodSet = true
                updateGradingPeriod(id: courseEnrollment?.currentGradingPeriodID)
                return getGrades(arrangeBy: arrangeBy, ignoreCache: true).eraseToAnyPublisher()
            }

            let assignmentSections: [GradeListData.AssignmentSections]
            switch arrangeBy {
            case .dueDate:
                assignmentSections = arrangeAssignmentsByDueDate(
                    assignments: $0.1
                )
            case .groupName:
                assignmentSections = arrangeAssignmentsByGroupNames(
                    assignments: $0.1
                )
            }

            return calculateTotalGrade(
                course: course,
                enrollments: enrollments,
                gradingPeriods: gradingPeriods
            )
            .map { [unowned self] totalGradeText in
                GradeListData(
                    id: UUID.string,
                    userID: userID ?? "",
                    courseName: course.name,
                    courseColor: course.color,
                    assignmentSections: assignmentSections,
                    isGradingPeriodHidden: isGradingPeriodHidden,
                    gradingPeriods: gradingPeriods,
                    currentGradingPeriod: getGradingPeriod(id: gradingPeriodID, gradingPeriods: gradingPeriods),
                    totalGradeText: totalGradeText
                )
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    public func updateGradingPeriod(id: String?) {
        gradingPeriodID = id
        enrollmentListStore = ReactiveStore(
            useCase: GetEnrollments(
                context: .course(courseID),
                userID: userID,
                gradingPeriodID: gradingPeriodID,
                types: ["StudentEnrollment"],
                states: [.active]
            )
        )

        assignmentListStore = ReactiveStore(
            useCase: GetAssignmentsByGroup(
                courseID: courseID,
                gradingPeriodID: gradingPeriodID,
                gradedOnly: true
            )
        )
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
                section.title == assignment.assignmentGroupSectionName
            }) {
                assignmentSections[index].assignments.append(assignment)
            } else {
                assignmentSections.append(
                    GradeListData.AssignmentSections(
                        id: UUID.string,
                        title: assignment.assignmentGroupSectionName,
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
            id: UUID.string,
            title: String(localized: "Overdue Assignments"),
            assignments: []
        )
        var upcomingAssignments = GradeListData.AssignmentSections(
            id: UUID.string,
            title: String(localized: "Upcoming Assignments"),
            assignments: []
        )
        var pastAssignments = GradeListData.AssignmentSections(
            id: UUID.string,
            title: String(localized: "Past Assignments"),
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
        gradingPeriods _: [GradingPeriod]
    ) -> AnyPublisher<String?, Never> {
        let courseEnrollment = course.enrollmentForGrades(userId: userID)
        let gradeEnrollment = enrollments.first {
            $0.id != nil &&
                $0.state == .active &&
                $0.userID == userID &&
                $0.type.lowercased().contains("student")
        }
        let hideQuantitativeData = course.hideQuantitativeData == true

        if course.hideFinalGrades == true {
            return Just(String(localized: "N/A")).eraseToAnyPublisher()
        } else if hideQuantitativeData {
            if let gradingPeriodID = gradingPeriodID {
                if let letterGrade = gradeEnrollment?.currentGrade(gradingPeriodID: gradingPeriodID) ?? gradeEnrollment?.finalGrade(gradingPeriodID: gradingPeriodID) {
                    return Just(letterGrade).eraseToAnyPublisher()
                } else {
                    return Just(gradeEnrollment?.convertedLetterGrade(
                        gradingPeriodID: gradingPeriodID,
                        gradingScheme: course.gradingScheme
                    )
                    ).eraseToAnyPublisher()
                }
            } else {
                if courseEnrollment?.multipleGradingPeriodsEnabled == true, courseEnrollment?.totalsForAllGradingPeriodsOption == false {
                    return Just(nil).eraseToAnyPublisher()
                } else if let letterGrade = courseEnrollment?.computedCurrentGrade ?? courseEnrollment?.computedFinalGrade ?? courseEnrollment?.computedCurrentLetterGrade {
                    return Just(letterGrade).eraseToAnyPublisher()
                } else {
                    return Just(courseEnrollment?.convertedLetterGrade(
                        gradingPeriodID: nil,
                        gradingScheme: course.gradingScheme
                    )
                    ).eraseToAnyPublisher()
                }
            }
        } else {
            var letterGrade: String?
            var localGrade: String?
            if let gradingPeriodID = gradingPeriodID {
                localGrade = gradeEnrollment?.formattedCurrentScore(gradingPeriodID: gradingPeriodID)
                letterGrade = gradeEnrollment?.currentGrade(gradingPeriodID: gradingPeriodID) ?? gradeEnrollment?.finalGrade(gradingPeriodID: gradingPeriodID)
            } else {
                localGrade = courseEnrollment?.formattedCurrentScore(gradingPeriodID: nil)
                if courseEnrollment?.multipleGradingPeriodsEnabled == true, courseEnrollment?.totalsForAllGradingPeriodsOption == false {
                    letterGrade = nil
                } else {
                    letterGrade = courseEnrollment?.computedCurrentGrade ?? courseEnrollment?.computedFinalGrade ?? courseEnrollment?.computedCurrentLetterGrade
                }
            }

            if let scoreText = localGrade, let letterGrade = letterGrade {
                return Just(scoreText + " (\(letterGrade))").eraseToAnyPublisher()
            } else {
                return Just(localGrade).eraseToAnyPublisher()
            }
        }
    }

    private func courseEnrollment(_ course: Course, userId: String?) -> Enrollment? {
        course.enrollmentForGrades(userId: userId)
    }
}
