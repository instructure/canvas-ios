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

import Combine
import Core

protocol ScoresInteractor {
    func getScores() -> AnyPublisher<ScoreDetails, Error>
}

final class ScoresInteractorLive: ScoresInteractor {
    private let courseID: String
    private let getCoursesInteractor: GetCoursesInteractor

    init(
        courseID: String,
        getCoursesInteractor: GetCoursesInteractor
    ) {
        self.courseID = courseID
        self.getCoursesInteractor = getCoursesInteractor
    }

    func getScores() -> AnyPublisher<ScoreDetails, Error> {
        Publishers.Zip(
            getAssignmentGroups(courseID: courseID),
            getCoursesInteractor.getCourse(id: courseID)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        )
        .map { assignmentGroups, course in
            ScoreDetails(
                totalScore: course?.enrollments.first?.computedFinalScore ?? 0.0,
                totalGrade: course?.enrollments.first?.computedFinalGrade ?? "N/A",
                assignmentGroups: assignmentGroups
            )
        }
        .eraseToAnyPublisher()
    }

    private func getAssignmentGroups(courseID: String) -> AnyPublisher<[HAssignmentGroup], Error> {
        ReactiveStore(
            useCase: GetAssignmentGroups(courseID: courseID)
        )
        .getEntities(ignoreCache: true)
        .flatMap { $0.publisher }
        .map { HAssignmentGroup(from: $0) }
        .collect()
        .eraseToAnyPublisher()
    }

    private func getTotalScore() {}
}

struct HAssignmentGroup {
    let id: String
    let name: String
    let groupWeight: Double?
    let assignments: [HAssignment]

    init(id: String, name: String, groupWeight: Double, assignments: [HAssignment]) {
        self.id = id
        self.name = name
        self.groupWeight = groupWeight
        self.assignments = assignments
    }

    init(from entity: Core.AssignmentGroup) {
        self.id = entity.id
        self.name = entity.name
        self.groupWeight = entity.groupWeight?.doubleValue
        if let assignments = entity.assignments {
            self.assignments = Array(assignments).map { HAssignment(from: $0) }
        } else {
            self.assignments = []
        }
    }
}

struct ScoreDetails {
    let totalScore: Double
    let totalGrade: String
    
    var totalGradeText: String {
        "\(String(totalScore))%"
    }
    
    let assignmentGroups: [HAssignmentGroup]
    var assignments: [HAssignment] {
        assignmentGroups.flatMap { $0.assignments }
    }
}
