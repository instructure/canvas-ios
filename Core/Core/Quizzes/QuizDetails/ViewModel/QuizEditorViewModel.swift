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

import Combine
import SwiftUI

public class QuizEditorViewModel: QuizEditorViewModelProtocol {
    @Environment(\.appEnvironment) var env
    @Published public private(set) var state: QuizEditorViewModelState = .loading

    public var assignment: Assignment?
    public let courseID: String
    public private(set) lazy var showErrorPopup: AnyPublisher<UIAlertController, Never> = showErrorPopupSubject.eraseToAnyPublisher()

    // Quiz attributes
    @Published public var title: String = ""
    @Published public var description: String = ""
    @Published public var quizType: QuizType = .assignment
    @Published public var published: Bool = false
    @Published public var assignmentGroup: AssignmentGroup?
    @Published public var assignmentGroups: [AssignmentGroup] = []
    @Published public var shuffleAnswers: Bool = false
    @Published public var timeLimit: Bool = false
    @Published public var lengthInMinutes: Double?
    @Published public var allowMultipleAttempts: Bool = false
    @Published public var scoreToKeep: ScoringPolicy?
    @Published public var allowedAttempts: Int?
    @Published public var oneQuestionAtaTime: Bool = false
    @Published public var lockQuestionAfterViewing: Bool = false
    @Published public var requireAccessCode: Bool = false
    @Published public var accessCode: String = ""
    @Published public var assignmentOverrides: [AssignmentOverridesEditor.Override] = []

    public var shouldShowPublishedToggle: Bool {
        quiz?.published == false || quiz?.unpublishable == true
    }

    public var availableQuizTypes = [QuizType.assignment, QuizType.practice_quiz, QuizType.graded_survey, QuizType.survey]

    private let quizID: String
    private var assignmentID: String?
    private var quiz: Quiz?
    private let showErrorPopupSubject = PassthroughSubject<UIAlertController, Never>()

    public init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
        fetchQuiz()
        fetchAssignmentGroups()
    }

    func fetchQuiz() {
        let useCase = GetQuiz(courseID: courseID, quizID: quizID)
        useCase.fetch(force: true) { [weak self] _, _, fetchError in
            guard let self = self else { return }
            if fetchError != nil {
                self.state = .error(fetchError?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: ""))
                return
            }

            self.quiz = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.assignmentID = self.quiz?.assignmentID
            self.fetchAssignment()
        }
    }

    func fetchAssignment() {
        guard let assignmentID = assignmentID else {
            loadAttributes()
            return
        }

        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID, include: GetAssignmentRequest.GetAssignmentInclude.allCases)
        useCase.fetch(force: true) { [weak self] _, _, fetchError in
            guard let self = self else { return }
            if fetchError != nil {
                self.state = .error(fetchError?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: ""))
                return
            }

            self.assignment = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.loadAttributes()
        }
    }

    func fetchAssignmentGroups() {
        let useCase = GetAssignmentGroups(courseID: courseID)
        useCase.fetch(force: true) { [weak self] _, _, fetchError in
            guard let self = self else { return }
            if fetchError != nil {
                self.state = .error(fetchError?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: ""))
                return
            }
            self.assignmentGroups = self.env.database.viewContext.fetch(scope: useCase.scope)
        }
    }

    func loadAttributes() {
        guard let quiz = quiz else { return }

        title = quiz.title
        description = quiz.details ?? ""
        assignmentGroup = assignment?.assignmentGroup
        quizType = quiz.quizType
        published = quiz.published

        shuffleAnswers = quiz.shuffleAnswers
        if let timeLimit = quiz.timeLimit {
            self.timeLimit = true
            lengthInMinutes = timeLimit
        }

        /* Scoring policy only registers on the API, if alloweed attempts > 1 */
        allowMultipleAttempts = ![0, 1].contains(quiz.allowedAttempts)
        scoreToKeep = quiz.scoringPolicy
        allowedAttempts = quiz.allowedAttempts < 2 ? nil : quiz.allowedAttempts

        oneQuestionAtaTime = quiz.oneQuestionAtATime
        lockQuestionAfterViewing = quiz.cantGoBack
        requireAccessCode = quiz.hasAccessCode
        accessCode = quiz.accessCode ?? ""
        assignmentOverrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) } ?? []

        self.state = .ready
    }

    func validate() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let errorMessage = NSLocalizedString("A title is required", comment: "")
            showError(title: errorMessage)
            return false
        }

        if requireAccessCode && accessCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let errorMessage = NSLocalizedString("You must enter an access code", comment: "")
            showError(title: errorMessage)
            return false
        }
        return true
    }

    private func showError(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("OK", comment: ""), style: .cancel))
        showErrorPopupSubject.send(alert)
    }

    public func doneTapped(router: Router, viewController: WeakViewController) {
        guard validate() else { return }

        state = .saving
        var allowedAttempts: Int?
        if allowMultipleAttempts {
            if let attempts = self.allowedAttempts, attempts > 1 {
                allowedAttempts = attempts
            } else {
                allowedAttempts = -1 // default is unlimited (-1)
            }
        } else {
            allowedAttempts = 0
        }

        let quizParams = APIQuizParameters(
            access_code: requireAccessCode ? accessCode: nil,
            allowed_attempts: allowedAttempts,
            assignment_group_id: assignmentGroup?.id,
            cant_go_back: oneQuestionAtaTime ? lockQuestionAfterViewing : nil,
            description: description,
            one_question_at_a_time: oneQuestionAtaTime,
            published: published,
            quiz_type: quizType,
            scoring_policy: allowMultipleAttempts ? scoreToKeep : nil,
            shuffle_answers: shuffleAnswers,
            time_limit: timeLimit ? lengthInMinutes : nil,
            title: title
        )

        UpdateQuiz(courseID: courseID, quizID: quizID, quiz: quizParams)
            .fetch { [weak self] result, _, error in performUIUpdate {
                guard let self = self else { return }
                if error != nil {
                    self.state = .ready
                    let errorMessage = error?.localizedDescription ?? NSLocalizedString("Something went wrong", comment: "")
                    self.showError(title: errorMessage)
                    return
                }
                if result != nil {
                    GetQuiz(courseID: self.courseID, quizID: self.quizID)
                        .fetch(force: true)
                    self.saveAssignment(router: router, viewController: viewController)
                }
            }
        }
    }

    func saveAssignment(router: Router, viewController: WeakViewController) {
        guard let assignmentID = assignmentID, let assignment = assignment else {
            router.dismiss(viewController)
            return
        }
        let (dueAt, unlockAt, lockAt, apiOverrides) = AssignmentOverridesEditor.apiOverrides(for: assignmentID, from: assignmentOverrides)

        UpdateAssignment(
            courseID: courseID,
            assignmentID: assignmentID,
            description: nil,
            dueAt: dueAt,
            gradingType: assignment.gradingType,
            lockAt: lockAt,
            name: title,
            onlyVisibleToOverrides: !assignmentOverrides.contains { $0.isEveryone },
            overrides: apiOverrides,
            pointsPossible: assignment.pointsPossible,
            published: published,
            unlockAt: unlockAt
        ).fetch { [weak self] result, _, error in performUIUpdate {
            guard let self = self else { return }
            if error != nil {
                // Practice quizzes don't necessary have assignments
                router.dismiss(viewController)
                return
            }
            if result != nil {
                GetAssignment(courseID: self.courseID, assignmentID: assignmentID, include: GetAssignmentRequest.GetAssignmentInclude.allCases)
                    .fetch(force: true)
                router.dismiss(viewController)
            }
        } }
    }
}
