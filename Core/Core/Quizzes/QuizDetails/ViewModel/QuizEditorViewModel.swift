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

public class QuizEditorViewModel: ObservableObject {

    public enum ViewModelState: Equatable {
        case loading
        case saving
        case error(String)
        case ready
    }

    @Environment(\.appEnvironment) var env

    @Published public private(set) var state: ViewModelState = .loading
    public var assignment: Assignment?
    public let courseID: String

    // Quiz attributes
    public var title: String = ""
    public var description: String = ""
    @Published public var quizType: QuizType = .assignment
    public var published: Bool = false
    public var shouldShowPublishedToggle: Bool {
        quiz?.published == false || quiz?.unpublishable == true
    }

    public var assignmentGroup: String = ""
    public var shuffleAnswers: Bool = false
    @Published public var timeLimit: Bool = false
    public var lengthInMinutes: Double?
    @Published public var allowMultipleAttempts: Bool = false
    @Published public var scoreToKeep: ScoringPolicy?
    public var allowedAttempts: Int?
    @Published public var seeResponses: Bool = false
    public var onlyOnceAfterEachAttempt: Bool = false
    @Published public var showCorrectAnswers: Bool = false
    public var showCorrectAnswersAt: Date?
    public var hideCorrectAnswersAt: Date?
    @Published public var oneQuestionAtaTime: Bool = false
    public var lockQuestionAfterViewing: Bool = false
    @Published public var requireAccessCode: Bool = false
    @Published public var accessCode: String = ""
    @Published public var assignmentOverrides: [AssignmentOverridesEditor.Override] = []

    private let quizID: String
    private var assignmentID: String?
    public var quiz: Quiz?

    public init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
        fetchQuiz()
    }

    func fetchQuiz() {
        let useCase = GetQuiz(courseID: courseID, quizID: quizID)
        useCase.fetch(force: true) { [weak self] _, _, _ in
            guard let self = self else { return }
            self.quiz = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.assignmentID = self.quiz?.assignmentID
            // alert = fetchError.map { .error($0) }
            self.fetchAssignment()
        }
    }

    func fetchAssignment() {
        guard let assignmentID = assignmentID else { return }
        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [ .overrides ])
        useCase.fetch(force: true) { [weak self] _, _, _ in
            guard let self = self else { return }
            self.assignment = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.loadAttributes()
            self.state = .ready
            // alert = fetchError.map { .error($0) }
        }
    }

    func fetchAssignmentGroups() {
        guard let assignmentID = assignmentID else { return }
        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [ .overrides ])
        useCase.fetch(force: true) { [weak self] _, _, _ in
            guard let self = self else { return }
            self.assignment = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.loadAttributes()
            self.state = .ready
            // alert = fetchError.map { .error($0) }
        }
    }

    func loadAttributes() {
        guard let quiz = quiz else { return }

        title = quiz.title
        description = quiz.details ?? ""
        // TODO assignment group
        quizType = quiz.quizType
        published = quiz.published

        shuffleAnswers = quiz.shuffleAnswers
        if let timeLimit = quiz.timeLimit {
            self.timeLimit = true
            lengthInMinutes = timeLimit
        }

        allowMultipleAttempts = ![0, 1].contains(quiz.allowedAttempts)
        scoreToKeep = quiz.scoringPolicy
        allowedAttempts = quiz.allowedAttempts

        seeResponses = quiz.hideResults != .always
        onlyOnceAfterEachAttempt = quiz.hideResults == .until_after_last_attempt
        showCorrectAnswers = quiz.showCorrectAnswers
        showCorrectAnswersAt = quiz.showCorrectAnswersAt
        hideCorrectAnswersAt = quiz.hideCorrectAnswersAt
        oneQuestionAtaTime = quiz.oneQuestionAtATime
        lockQuestionAfterViewing = quiz.cantGoBack
        requireAccessCode = quiz.hasAccessCode
        accessCode = quiz.accessCode ?? ""
        assignmentOverrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) } ?? []
    }

    func validate() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state = .error(NSLocalizedString("A title is required", comment: ""))
            return false
        }

        if showCorrectAnswers, let show = showCorrectAnswersAt, let hide = hideCorrectAnswersAt, hide < show {
            state = .error(NSLocalizedString("'Hide Date' cannot be before 'Show Date'", comment: ""))
            return false
        }

        if requireAccessCode, accessCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state = .error(NSLocalizedString("You must enter an access code", comment: ""))
            return false
        }
        //TODO assignmentOverridesEditor

        return true
    }

    public func doneTapped(router: Router, viewController: WeakViewController) {
        state = .saving

        guard validate() else { return }

        var allowedAttempts: Int?
        if allowMultipleAttempts {
            allowedAttempts = self.allowedAttempts ?? -1 // default is unlimited (-1)
        } else {
            allowedAttempts = 0
        }

        let quizParams = APIQuizParameters(
            title: title,
            description: description,
            quiz_type: quizType,
            time_limit: timeLimit ? lengthInMinutes : nil,
            shuffle_answers: shuffleAnswers,
            show_correct_answers: seeResponses ? showCorrectAnswers : nil,
            scoring_policy: allowMultipleAttempts ? scoreToKeep : nil,
            allowed_attempts: allowedAttempts,
            one_question_at_a_time: oneQuestionAtaTime, // TODO
            cant_go_back: oneQuestionAtaTime ? lockQuestionAfterViewing : nil,
            access_code: requireAccessCode ? accessCode : nil,
            published: published,
            hide_results: seeResponses ?
                (onlyOnceAfterEachAttempt ? .until_after_last_attempt : nil)
                : .always,
            show_correct_answers_at: seeResponses && showCorrectAnswers ? showCorrectAnswersAt : nil,
            hide_correct_answers_at: seeResponses && showCorrectAnswers ? hideCorrectAnswersAt : nil,
            assignment_group_id: assignmentGroup,
            overrides: nil
        )

        UpdateQuiz(courseID: courseID, quizID: quizID, quiz: quizParams)
            .fetch { [weak self] result, _, error in performUIUpdate {
                guard let self = self else { return }
                self.state = .ready

                // alert = fetchError.map { .error($0) }
                if error != nil {
                    self.state = .error(error?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: ""))
                }
                if result != nil {
                    // TODO Get Quiz and Assingment
                    // GetAssignment(courseID: self.courseID, assignmentID: self.assignmentID, include: [ .overrides ])
                       // .fetch(force: true) // updated overrides & allDates aren't in result
                    router.dismiss(viewController)
                }
            } }
    }
}
