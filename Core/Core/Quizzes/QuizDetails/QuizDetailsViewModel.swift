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

import SwiftUI

public class QuizDetailsViewModel: ObservableObject {

    public enum ViewModelState<T: Equatable, U: Equatable>: Equatable {
        case loading
        case error
        case data(T, U)
    }
    @Environment(\.appEnvironment) private var env
    public let quizID: String
    public let courseID: String

    @Published public private(set) var state: ViewModelState<Quiz, Assignment> = .loading
    @Published public private(set) var courseColor: UIColor?

    public var title: String { NSLocalizedString("Quiz Details", comment: "") }
    public var subtitle: String { course.first?.name ?? "" }
    public var showSubmissions: Bool { course.first?.enrollments?.contains(where: { $0.isTeacher || $0.isTA }) == true }

    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    private lazy var quiz = env.subscribe(GetQuiz(courseID: courseID, quizID: quizID)) { [weak self] in
        self?.quizDidUpdate()
    }

    private var assignment: Store<GetAssignment>?

    public init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
    }

    public func viewDidAppear() {
        quiz.refresh()
        course.refresh()
    }

    public func editTapped(router: Router, viewController: WeakViewController) {
        env.router.route(
            to: "courses/\(courseID)/assignments/\(quizID)/edit",
            from: viewController,
            options: .modal(.formSheet, isDismissable: false, embedInNav: true)
        )
    }

    public func launchPreview(router: Router, viewController: WeakViewController) {
        env.router.route(
            to: "courses/\(courseID)/quizzes/\(quizID)/preview",
            from: viewController,
            options: .modal(.fullScreen, isDismissable: false, embedInNav: true)
        )
    }

    public struct QuizAttribute: Identifiable {
        public var id: String
        public var value: String

        public init(_ id: String, _ value: String) {
            self.id = id
            self.value = value
        }
    }

    public var attributes: [QuizAttribute] {
        guard let quiz = quiz.first else { return [] }
        var attributes = [QuizAttribute]()
        attributes.append(QuizAttribute(
            NSLocalizedString("Quiz Type:", bundle: .core, comment: ""),
            quiz.quizType.sectionTitle
        ))

        /*TODO
        Line(Text("Assignment Group:", bundle: .core), Text("TODO"))
        if let assignmentGroup = assignment.assignmentGroup?.name {
            Line(Text("Assignment Group:", bundle: .core), Text(assignmentGroup))
        }*/

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

        //TODO

        let showCorrectAnswers = "TODO"
        attributes.append(QuizAttribute(
            NSLocalizedString("Show Correct Answers:", bundle: .core, comment: ""),
            showCorrectAnswers
        ))

        let oneQuestionAtATime = quiz.oneQuestionAtATime ?
            NSLocalizedString("Yes", bundle: .core, comment: "") :
            NSLocalizedString("No", bundle: .core, comment: "")
        attributes.append(QuizAttribute(
            NSLocalizedString("One Question at a Time:", bundle: .core, comment: ""),
            oneQuestionAtATime
        ))

        let lockQuestionsAfterAnswering = quiz.oneQuestionAtATime == true && quiz.cantGoBack ?
            NSLocalizedString("Yes", bundle: .core, comment: "") :
            NSLocalizedString("No", bundle: .core, comment: "")
        attributes.append(QuizAttribute(
            NSLocalizedString("Lock Questions After Answering:", bundle: .core, comment: ""),
            lockQuestionsAfterAnswering
        ))

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
        
        return attributes
    }

    private func showCorrectAnswers(quiz: Quiz) -> String? {

        if (quiz.showCorrectAnswers) {
            if let showCorrectAnswersAt = quiz.showCorrectAnswersAt, quiz.hideCorrectAnswersAt == nil {
                let template = NSLocalizedString("After %@", bundle: .core, comment: "")
                return String.localizedStringWithFormat(template, showCorrectAnswersAt.relativeDateTimeString)
            }
          /*
          if (quiz.hide_correct_answers_at && !quiz.show_correct_answers_at) {
            return i18n('Until {date}', { date: formattedDueDate(extractDateFromString(quiz.hide_correct_answers_at)) })
          }
          if (quiz.show_correct_answers_at && quiz.hide_correct_answers_at) {
            return i18n('{show} to {hide}', {
              show: formattedDueDate(extractDateFromString(quiz.show_correct_answers_at)),
              hide: formattedDueDate(extractDateFromString(quiz.hide_correct_answers_at)),
            })
          }
          if (quiz.show_correct_answers_last_attempt && quiz.allowed_attempts > 0) {
            return i18n('After Last Attempt')
          }
           */
          return quiz.hideResults != nil ? nil : NSLocalizedString("Always", bundle: .core, comment: "")
        }

        return quiz.hideResults != nil ? nil : NSLocalizedString("No", bundle: .core, comment: "")
    }

    private func courseDidUpdate() {
        courseColor = course.first?.color
    }

    private func quizDidUpdate() {
        if quiz.requested, quiz.pending { return }
        if let quiz = quiz.first, let assignmentID = quiz.assignmentID {
            assignment = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID))  { [weak self] in
                self?.assignmentDidUpdate()
            }
            assignment?.refresh()
        } else {
            state = .error
        }
    }

    private func assignmentDidUpdate() {
        if assignment?.requested == true, assignment?.pending != false { return }
        if let quiz = quiz.first, let assignment = assignment?.first {
            state = .data(quiz, assignment)
        } else {
            state = .error
        }
    }
}

extension QuizDetailsViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        quiz.refresh(force: true) { [weak self] _ in
            completion()
        }
    }
}
