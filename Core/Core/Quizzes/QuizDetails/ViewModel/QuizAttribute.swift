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
            NSLocalizedString("Quiz Type:", bundle: .core, comment: ""),
            quizType
        ))

        if let assignmentGroupName = assignment?.assignmentGroup?.name {
            attributes.append(QuizAttribute(
                NSLocalizedString("Assignment Group:", bundle: .core, comment: ""),
                assignmentGroupName
            ))
        }

        let shuffleAnswers = quiz.shuffleAnswers ?
            NSLocalizedString("Yes", bundle: .core, comment: "") :
            NSLocalizedString("No", bundle: .core, comment: "")
        attributes.append(QuizAttribute(
            NSLocalizedString("Shuffle Answers:", bundle: .core, comment: ""),
            shuffleAnswers
        ))

        var timeLimitText = NSLocalizedString("No time Limit", bundle: .core, comment: "")
        if let timeLimit = quiz.timeLimit {
            let timeLimitTemplate = NSLocalizedString("%d Minutes", bundle: .core, comment: "")
            timeLimitText = String.localizedStringWithFormat(timeLimitTemplate, Int(timeLimit))
        }

        attributes.append(QuizAttribute(
            NSLocalizedString("Time Limit:", bundle: .core, comment: ""),
            timeLimitText
        ))

        attributes.append(QuizAttribute(
            NSLocalizedString("Allowed Attempts:", bundle: .core, comment: ""),
            quiz.allowedAttemptsText
        ))

        var hideResultsText = NSLocalizedString("Always", bundle: .core, comment: "")
        if let hideResults = quiz.hideResults {
            hideResultsText = hideResults.text
        }
        attributes.append(QuizAttribute(
            NSLocalizedString("View Responses:", bundle: .core, comment: ""),
            hideResultsText
        ))

        if let showCorrectAnswers = showCorrectAnswers(quiz: quiz) {
            attributes.append(QuizAttribute(
                NSLocalizedString("Show Correct Answers:", bundle: .core, comment: ""),
                showCorrectAnswers
            ))
        }

        let oneQuestionAtATime = quiz.oneQuestionAtATime ?
            NSLocalizedString("Yes", bundle: .core, comment: "") :
            NSLocalizedString("No", bundle: .core, comment: "")
        attributes.append(QuizAttribute(
            NSLocalizedString("One Question at a Time:", bundle: .core, comment: ""),
            oneQuestionAtATime
        ))

        if quiz.oneQuestionAtATime == true {
            let lockQuestionsAfterAnswering = quiz.cantGoBack ?
                NSLocalizedString("Yes", bundle: .core, comment: "") :
                NSLocalizedString("No", bundle: .core, comment: "")
            attributes.append(QuizAttribute(
                NSLocalizedString("Lock Questions After Answering:", bundle: .core, comment: ""),
                lockQuestionsAfterAnswering
            ))
        }

        if let scoringPolicy = quiz.scoringPolicy {
            attributes.append(QuizAttribute(
                NSLocalizedString("Score to Keep:", bundle: .core, comment: ""),
                scoringPolicy.text
            ))
        }

        if let accessCode = quiz.accessCode {
            attributes.append(QuizAttribute(
                NSLocalizedString("Access Code:", bundle: .core, comment: ""),
                accessCode
            ))
        }
    }

    private func showCorrectAnswers(quiz: Quiz) -> String? {
        if quiz.showCorrectAnswers {
            if let showCorrectAnswersAt = quiz.showCorrectAnswersAt, quiz.hideCorrectAnswersAt == nil {
                let template = NSLocalizedString("After %@", bundle: .core, comment: "e.g. After 01.02.2022")
                return String.localizedStringWithFormat(template, showCorrectAnswersAt.relativeDateTimeString)
            }
            if let hideCorrectAnswersAt = quiz.hideCorrectAnswersAt, quiz.showCorrectAnswersAt == nil {
                let template = NSLocalizedString("Until %@", bundle: .core, comment: "e.g. Until 01.02.2022")
                return String.localizedStringWithFormat(template, hideCorrectAnswersAt.relativeDateTimeString)
            }
            if let showCorrectAnswersAt = quiz.showCorrectAnswersAt, let hideCorrectAnswersAt = quiz.hideCorrectAnswersAt {
                let template = NSLocalizedString("%@ to %@", bundle: .core, comment: "e.g 01.02.2022 to 01.03.2022")
                return String.localizedStringWithFormat(template, showCorrectAnswersAt.relativeDateTimeString, hideCorrectAnswersAt.relativeDateTimeString)
            }
            if quiz.showCorrectAnswersLastAttempt && quiz.allowedAttempts > 0 {
                return NSLocalizedString("After Last Attempt", bundle: .core, comment: "")
            }

            return quiz.hideResults != nil ? nil : NSLocalizedString("Always", bundle: .core, comment: "")
        }

        return quiz.hideResults != nil ? nil : NSLocalizedString("No", bundle: .core, comment: "")
    }
}
