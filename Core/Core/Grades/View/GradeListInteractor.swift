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

protocol GradeListInteractor {
    func getGrades(byAscendingOrder: Bool) -> AnyPublisher<GradeListData, Error>
    func refresh() -> AnyPublisher<Void, Never>
    func updateGradingPeriod(id: String?) -> AnyPublisher<Void, Never>
}

final class GradeListInteractorLive: GradeListInteractor {
    private let courseID: String
    private var gradingPeriodID: String?
    private let userID: String?
    private let offlineInteractor: OfflineModeInteractor

    private var assignmentListStore: ReactiveStore<GetAssignmentsByGroup>
    private let colorListStore: ReactiveStore<GetCustomColors>
    private let courseStore: ReactiveStore<GetCourse>
    private var enrollmentListStore: ReactiveStore<GetEnrollments>
    private let gradingPeriodListStore: ReactiveStore<GetGradingPeriods>

    private var initialGradingPeriodID: String?

    init(
        courseID: String,
        gradingPeriodID: String?,
        userID: String?,
        offlineInteractor: OfflineModeInteractor = OfflineModeAssembly.make()
    ) {
        self.courseID = courseID
        self.gradingPeriodID = gradingPeriodID
        self.userID = userID
        self.offlineInteractor = offlineInteractor

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

    public func getGrades(byAscendingOrder: Bool) -> AnyPublisher<GradeListData, Error> {
        Publishers.CombineLatest3(
            assignmentListStore.getEntities(loadAllPages: true, keepObservingDatabaseChanges: true),
            colorListStore.getEntities(),
            courseStore.getEntities(keepObservingDatabaseChanges: true).compactMap { $0.first }
        )
        .combineLatest(
            enrollmentListStore.getEntities(loadAllPages: true, keepObservingDatabaseChanges: true),
            gradingPeriodListStore.getEntities(loadAllPages: true)
        )
        .flatMapLatest { [unowned self] in
            let assignmentSections = mapAssignmentsBySections(
                isAscending: byAscendingOrder,
                assignments: $0.0.0
            )
            let colors = $0.0.1
            let course = $0.0.2
            let enrollments = $0.1
            let gradingPeriods = $0.2
            let isGradingPeriodHidden = course.enrollmentForGrades(userId: userID)?.multipleGradingPeriodsEnabled == false

            return calculateTotalGrade(
                course: course,
                enrollments: enrollments,
                gradingPeriods: gradingPeriods
            )
            .map { [unowned self] totalGradeText in
                GradeListData(
                    userID: userID ?? "",
                    courseName: course.name,
                    assignmentSections: assignmentSections,
                    colors: colors,
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

    public func updateGradingPeriod(id: String?) -> AnyPublisher<Void, Never> {
        gradingPeriodID = id
        if initialGradingPeriodID == nil {
            initialGradingPeriodID = id
        }

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

        return Publishers.CombineLatest(
            enrollmentListStore.forceRefresh(),
            assignmentListStore.forceRefresh()
        )
        .mapToVoid()
        .eraseToAnyPublisher()

//        // In offline mode we don't want to delete anything from CoreData
//        if offlineModeInteractor?.isOfflineModeEnabled() == false {
//            // Delete assignment groups immediately, to see a spinner again
//            assignments.useCase.reset(context: env.database.viewContext)
//            try? env.database.viewContext.save()
//        }
//
//        assignments.refresh(force: true)
//        enrollments.refresh(force: true)
    }

    public func refresh() -> AnyPublisher<Void, Never> {
        [
            assignmentListStore.forceRefresh(),
            colorListStore.forceRefresh(),
            courseStore.forceRefresh(),
            enrollmentListStore.forceRefresh(),
            gradingPeriodListStore.forceRefresh(),
        ]
        .combineLatest()
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private func getGradingPeriod(id: String?, gradingPeriods: [GradingPeriod]) -> GradingPeriod? {
        guard let id else {
            return nil
        }
        return gradingPeriods.filter { $0.id == id }.first
    }

    private func mapAssignmentsBySections(
        isAscending: Bool,
        assignments: [Assignment]
    ) -> [GradeListData.AssignmentSections] {
        let orderedAssignments = assignments.sorted {
            if isAscending {
                $0.dueAtSortNilsAtBottom ?? Date.distantFuture < $1.dueAtSortNilsAtBottom ?? Date.distantFuture
            } else {
                $0.dueAtSortNilsAtBottom ?? Date.distantFuture > $1.dueAtSortNilsAtBottom ?? Date.distantFuture
            }
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
        if initialGradingPeriodID != courseEnrollment?.currentGradingPeriodID {
            return updateGradingPeriod(id: courseEnrollment?.currentGradingPeriodID)
                .flatMap { _ in
                    Empty(completeImmediately: false).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        let hideQuantitativeData = course.hideQuantitativeData == true

        if course.hideFinalGrades == true {
            return Just(NSLocalizedString("N/A", bundle: .core, comment: "")).eraseToAnyPublisher()
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
