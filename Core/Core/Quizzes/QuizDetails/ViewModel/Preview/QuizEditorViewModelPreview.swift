//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

#if DEBUG

import Combine

/**
Use only for SwiftUI previews.
*/
public class QuizEditorViewModelPreview: QuizEditorViewModelProtocol {
    public var state: QuizEditorViewModelState
    public var assignment: Assignment?
    public var courseID: String = ""
    public var showErrorPopup: AnyPublisher<UIAlertController, Never> = PassthroughSubject().eraseToAnyPublisher()
    public var title: String = ""
    public var description: String = ""
    public var quizType: QuizType = .assignment
    public var published: Bool = false
    public var assignmentGroup: AssignmentGroup?
    public var shuffleAnswers: Bool = false
    public var timeLimit: Bool = false
    public var lengthInMinutes: Double?
    public var allowMultipleAttempts: Bool = false
    public var scoreToKeep: ScoringPolicy?
    public var allowedAttempts: Int?
    public var oneQuestionAtaTime: Bool = false
    public var lockQuestionAfterViewing: Bool = false
    public var requireAccessCode: Bool = false
    public var accessCode: String = ""
    public var assignmentOverrides: [AssignmentOverridesEditor.Override] = []
    public var shouldShowPublishedToggle: Bool = true

    public init(
        state: QuizEditorViewModelState,
        courseID: String,
        title: String,
        description: String,
        quizType: QuizType,
        published: Bool,
        shuffleAnswers: Bool,
        timeLimit: Bool,
        lengthInMinutes: Double?,
        allowMultipleAttempts: Bool,
        scoreToKeep: ScoringPolicy?,
        allowedAttempts: Int?,
        oneQuestionAtaTime: Bool,
        lockQuestionAfterViewing: Bool,
        requireAccessCode: Bool,
        accessCode: String
    ) {
        self.state = state
        self.assignment = Assignment.save(.make(), in: PreviewEnvironment().globalDatabase.viewContext, updateSubmission: false, updateScoreStatistics: false)
        self.courseID = courseID
        self.title = title
        self.description = description
        self.quizType = quizType
        self.published = published
        self.shuffleAnswers = shuffleAnswers
        self.timeLimit = timeLimit
        self.lengthInMinutes = lengthInMinutes
        self.allowMultipleAttempts = allowMultipleAttempts
        self.scoreToKeep = scoreToKeep
        self.allowedAttempts = allowedAttempts
        self.oneQuestionAtaTime = oneQuestionAtaTime
        self.lockQuestionAfterViewing = lockQuestionAfterViewing
        self.requireAccessCode = requireAccessCode
        self.accessCode = accessCode
    }

    public init(state: QuizEditorViewModelState) {
        self.state = state
        self.assignment = Assignment.save(.make(), in: PreviewEnvironment().globalDatabase.viewContext, updateSubmission: false, updateScoreStatistics: false)
    }

    public func doneTapped(router: Router, viewController: WeakViewController) {}
    public func quizTypeTapped(router: Router, viewController: WeakViewController) {}
    public func assignmentGroupTapped(router: Router, viewController: WeakViewController) {}
    public func scoreToKeepTapped(router: Router, viewController: WeakViewController) {}
    public func isModallyPresented(viewController: UIViewController) -> Bool { true }
}

#endif
