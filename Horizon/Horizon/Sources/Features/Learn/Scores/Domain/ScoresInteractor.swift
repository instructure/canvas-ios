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
import Foundation

protocol ScoresInteractor {
    var courseID: String { get }
    func getScores(sortedBy: ScoreDetails.SortOption, ignoreCache: Bool) -> AnyPublisher<ScoreDetails, Error>
}

final class ScoresInteractorLive: ScoresInteractor {
    // MARK: - Dependencies

    let courseID: String
    private let enrollmentID: String
    private let userId: String

    // MARK: - Init

    init(
        courseID: String,
        enrollmentID: String,
        userId: String = AppEnvironment.shared.currentSession?.userID ?? ""
    ) {
        self.courseID = courseID
        self.enrollmentID = enrollmentID
        self.userId = userId
    }

    func getScores(sortedBy: ScoreDetails.SortOption, ignoreCache: Bool) -> AnyPublisher<ScoreDetails, Error> {
        unowned let unownedSelf = self
        return Publishers.Zip(
            fetchAssignmentGroups(ignoreCache: ignoreCache),
            getCourse(courseID: courseID, ignoreCache: ignoreCache)
        )
        .map { assignmentGroups, course in
            ScoreDetails(
                score: unownedSelf.calculateFinalScoreAndGradeText(course: course),
                assignmentGroups: assignmentGroups,
                sortOption: sortedBy
            )
        }
        .eraseToAnyPublisher()
    }

    private func fetchAssignmentGroups(ignoreCache: Bool) -> AnyPublisher<[ScoresAssignmentGroup], Error> {
         ReactiveStore(useCase: GetSubmissionScoresUseCase(userId: userId, enrollmentId: enrollmentID))
             .getEntities(ignoreCache: ignoreCache)
             .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
             .map { response in
                 ScoresAssignmentGroup(from: response)
             }
             .collect()
             .eraseToAnyPublisher()
     }

    private func getCourse(courseID: String, ignoreCache: Bool) -> AnyPublisher<ScoresCourse, Error> {
        ReactiveStore(
            useCase: GetScoresCourseUseCase(courseID: courseID)
        )
        .getEntities(ignoreCache: ignoreCache)
        .compactMap { $0.first }
        .map { ScoresCourse(from: $0) }
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
           let grade = enrollment.grade {
            return grade // Returns e.g "C-"
        } else if let scoreString = scoreGradeString(enrollment: enrollment) {
            return scoreString
        }

        return naText
    }

    private func scoreGradeString(enrollment: ScoresCourseEnrollment) -> String? {
        var scoreString: String?
        let score = 36.52341
        if let formattedScore = GradeFormatter.horizonNumberFormatter.string(
               from: GradeFormatter.truncate(score)
           ) {
            scoreString = "\(formattedScore)%"
        }

        let letterGrade: String?
        if let computedFinalGrade = enrollment.grade {
            letterGrade = "(\(computedFinalGrade))"
        } else {
            letterGrade = nil
        }
        let scoreGradesString = [scoreString, letterGrade].compactMap { $0 }.joined(separator: " ")

        return scoreGradesString.isEmpty ? nil : scoreGradesString
    }
}

extension GradeFormatter {
    public static let horizonNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter
    }()
}
