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

import Combine
import SwiftUI

public protocol QuizEditorViewModelProtocol: ObservableObject {
    var state: QuizEditorViewModelState { get }
    var assignment: Assignment? { get }
    var courseID: String { get }
    var showErrorPopup: AnyPublisher<UIAlertController, Never> { get }

    var title: String { get set }
    var description: String { get set }
    var quizType: QuizType { get set }
    var published: Bool { get set }
    var assignmentGroup: AssignmentGroup? { get set }
    var shuffleAnswers: Bool { get set }
    var timeLimit: Bool { get set }
    var lengthInMinutes: Double? { get set }
    var allowMultipleAttempts: Bool { get set }
    var scoreToKeep: ScoringPolicy? { get set }
    var allowedAttempts: Int? { get set }
    var oneQuestionAtaTime: Bool { get set }
    var lockQuestionAfterViewing: Bool { get set }
    var requireAccessCode: Bool { get set }
    var accessCode: String { get set }
    var assignmentOverrides: [AssignmentOverridesEditor.Override] { get set }
    var shouldShowPublishedToggle: Bool { get }

    func doneTapped(router: Router, viewController: WeakViewController)
    func quizTypeTapped(router: Router, viewController: WeakViewController)
    func assignmentGroupTapped(router: Router, viewController: WeakViewController)
    func scoreToKeepTapped(router: Router, viewController: WeakViewController)

    func isModallyPresented(viewController: UIViewController) -> Bool
}

public enum QuizEditorViewModelState: Equatable {
    case loading
    case error(String)
    case ready
}
