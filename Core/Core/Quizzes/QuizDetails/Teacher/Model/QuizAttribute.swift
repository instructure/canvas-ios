//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct QuizAttribute: Identifiable {
    public var id: String
    public var value: String

    public init(_ id: String, _ value: String) {
        self.id = id
        self.value = value
    }
}

public struct QuizAttributes {

    public var attributes: [QuizAttribute]

    public init(quiz: Quiz, assignment: Assignment?) {
        attributes = [QuizAttribute]()

        let quizType = quiz.quizType.name
        attributes.append(QuizAttribute(
            String(localized: "Quiz Type:", bundle: .core),
            quizType
        ))

        if let assignmentGroupName = assignment?.assignmentGroup?.name {
            attributes.append(QuizAttribute(
                String(localized: "Assignment Group:", bundle: .core),
                assignmentGroupName
            ))
        }

        let shuffleAnswers = quiz.shuffleAnswers ?
            String(localized: "Yes", bundle: .core) :
            String(localized: "No", bundle: .core)
        attributes.append(QuizAttribute(
            String(localized: "Shuffle Answers:", bundle: .core),
            shuffleAnswers
        ))

        var timeLimitText = String(localized: "No time Limit", bundle: .core)
        if let timeLimit = quiz.timeLimit {
            let timeLimitTemplate = String(localized: "%d Minutes", bundle: .core)
            timeLimitText = String.localizedStringWithFormat(timeLimitTemplate, Int(timeLimit))
        }

        attributes.append(QuizAttribute(
            String(localized: "Time Limit:", bundle: .core),
            timeLimitText
        ))

        attributes.append(QuizAttribute(
            String(localized: "Allowed Attempts:", bundle: .core),
            quiz.allowedAttemptsText
        ))

        var hideResultsText = String(localized: "Always", bundle: .core)
        if let hideResults = quiz.hideResults {
            hideResultsText = hideResults.text
        }
        attributes.append(QuizAttribute(
            String(localized: "View Responses:", bundle: .core),
            hideResultsText
        ))

        if let showCorrectAnswers = showCorrectAnswers(quiz: quiz) {
            attributes.append(QuizAttribute(
                String(localized: "Show Correct Answers:", bundle: .core),
                showCorrectAnswers
            ))
        }

        let oneQuestionAtATime = quiz.oneQuestionAtATime ?
            String(localized: "Yes", bundle: .core) :
            String(localized: "No", bundle: .core)
        attributes.append(QuizAttribute(
            String(localized: "One Question at a Time:", bundle: .core),
            oneQuestionAtATime
        ))

        if quiz.oneQuestionAtATime == true {
            let lockQuestionsAfterAnswering = quiz.cantGoBack ?
                String(localized: "Yes", bundle: .core) :
                String(localized: "No", bundle: .core)
            attributes.append(QuizAttribute(
                String(localized: "Lock Questions After Answering:", bundle: .core),
                lockQuestionsAfterAnswering
            ))
        }

        if let scoringPolicy = quiz.scoringPolicy {
            attributes.append(QuizAttribute(
                String(localized: "Score to Keep:", bundle: .core),
                scoringPolicy.text
            ))
        }

        if let accessCode = quiz.accessCode {
            attributes.append(QuizAttribute(
                String(localized: "Access Code:", bundle: .core),
                accessCode
            ))
        }
    }

    private func showCorrectAnswers(quiz: Quiz) -> String? {
        if quiz.showCorrectAnswers {
            if let showCorrectAnswersAt = quiz.showCorrectAnswersAt, quiz.hideCorrectAnswersAt == nil {
                let template = String(localized: "After %@", bundle: .core, comment: "e.g. After 01.02.2022")
                return String.localizedStringWithFormat(template, showCorrectAnswersAt.relativeDateTimeString)
            }
            if let hideCorrectAnswersAt = quiz.hideCorrectAnswersAt, quiz.showCorrectAnswersAt == nil {
                let template = String(localized: "Until %@", bundle: .core, comment: "e.g. Until 01.02.2022")
                return String.localizedStringWithFormat(template, hideCorrectAnswersAt.relativeDateTimeString)
            }
            if let showCorrectAnswersAt = quiz.showCorrectAnswersAt, let hideCorrectAnswersAt = quiz.hideCorrectAnswersAt {
                let template = String(localized: "%@ to %@", bundle: .core, comment: "e.g 01.02.2022 to 01.03.2022")
                return String.localizedStringWithFormat(template, showCorrectAnswersAt.relativeDateTimeString, hideCorrectAnswersAt.relativeDateTimeString)
            }
            if quiz.showCorrectAnswersLastAttempt && quiz.allowedAttempts > 0 {
                return String(localized: "After Last Attempt", bundle: .core)
            }

            return quiz.hideResults != nil ? nil : String(localized: "Always", bundle: .core)
        }

        return quiz.hideResults != nil ? nil : String(localized: "No", bundle: .core)
    }
}
