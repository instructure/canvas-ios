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
    func getScores(sortedBy: ScoreDetails.SortOption) -> AnyPublisher<ScoreDetails, Error>
}

final class ScoresInteractorLive: ScoresInteractor {
    private let courseID: String
    private let submissionCommentInteractor: SubmissionCommentInteractor

    init(
        courseID: String,
        submissionCommentInteractor: SubmissionCommentInteractor = SubmissionCommentAssembly.makeSubmissionCommentInteractor()
    ) {
        self.courseID = courseID
        self.submissionCommentInteractor = submissionCommentInteractor
    }

    func getScores(sortedBy: ScoreDetails.SortOption) -> AnyPublisher<ScoreDetails, Error> {
        Publishers.Zip(
            getAssignmentGroups(courseID: courseID),
            getCourse(courseID: courseID)
        )
        .flatMap { assignmentGroups, course in
            self.getScoreDetails(
                course: course,
                assignmentGroups: assignmentGroups,
                sortBy: sortedBy
            )
        }
        .eraseToAnyPublisher()
    }

    private func getCourse(courseID: String) -> AnyPublisher<ScoresCourse, Error> {
        ReactiveStore(
            useCase: GetScoresCourseUseCase(courseID: courseID)
        )
        .getEntities()
        .compactMap { $0.first }
        .map { ScoresCourse(from: $0) }
        .eraseToAnyPublisher()
    }

    private func getAssignmentGroups(courseID: String) -> AnyPublisher<[HAssignmentGroup], Error> {
        ReactiveStore(
            useCase: GetAssignmentGroups(courseID: courseID)
        )
        .getEntities()
        .flatMap { $0.publisher }
        .map { HAssignmentGroup(from: $0) }
        .collect()
        .eraseToAnyPublisher()
    }

    private func getScoreDetails(
        course: ScoresCourse,
        assignmentGroups: [HAssignmentGroup],
        sortBy: ScoreDetails.SortOption
    ) -> AnyPublisher<ScoreDetails, Error> {
        unowned let unownedSelf = self

        return assignmentGroups
            .publisher
            .flatMap { assignmentGroup -> AnyPublisher<HAssignmentGroup, Error> in
                assignmentGroup.assignments
                    .publisher
                    .flatMap {
                        unownedSelf.getCommentsForAsssignment(
                            courseID: course.courseID,
                            assignment: $0
                        )
                    }
                    .collect()
                    .map { assignmentGroup.update(assignments: $0) }
                    .eraseToAnyPublisher()
            }
            .collect()
            .map {
                ScoreDetails(
                    score: unownedSelf.calculateFinalScoreAndGradeText(course: course),
                    assignmentGroups: $0,
                    sortOption: sortBy
                )
            }
            .eraseToAnyPublisher()
    }

    private func getCommentsForAsssignment(
        courseID: String,
        assignment: HAssignment
    ) -> AnyPublisher<HAssignment, Error> {
        submissionCommentInteractor.getNumberOfComments(
            courseID: courseID,
            assignmentID: assignment.id,
            attempt: assignment.mostRecentSubmission?.attempt
        )
        .map { numberOfComments -> HAssignment in
            var updatedSubmissions = assignment.submissions
            if let mostRecentSubmission = updatedSubmissions.first {
                updatedSubmissions[0] = mostRecentSubmission.update(numberOfComments: numberOfComments)
            }
            return assignment.update(submissions: updatedSubmissions)
        }
        .eraseToAnyPublisher()
    }

    private func calculateFinalScoreAndGradeText(course: ScoresCourse) -> String {
        let naText = String(localized: "N/A", bundle: .horizon)

        guard let enrollment = course.enrollments.first else {
            return naText
        }

        if course.settings.hideFinalGrade {
            return naText
        }

        if course.settings.restrictQuantitativeData,
           let computedFinalGrade = enrollment.computedFinalGrade {
            return computedFinalGrade // Returns e.g "C-"
        } else if let computedFinalScore = enrollment.computedFinalScore,
                  let computedFinalGrade = enrollment.computedFinalGrade,
                  let formattedScore = GradeFormatter.numberFormatter.string(
                      from: GradeFormatter.truncate(computedFinalScore)
                  ) {
            return "\(formattedScore)% (\(computedFinalGrade))"
        }

        return naText
    }
}
