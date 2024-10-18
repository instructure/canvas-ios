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

public protocol TeacherQuizDetailsViewModel: ObservableObject, Refreshable {
    var state: QuizDetailsViewModelState { get }
    var courseColor: UIColor? { get }
    var title: String { get }
    var subtitle: String { get }
    var quizTitle: String { get }
    var pointsPossibleText: String { get }
    var published: Bool { get }
    var quizDetailsHTML: String? { get }
    var showSubmissions: Bool { get }
    var assignmentSubmissionBreakdownViewModel: AssignmentSubmissionBreakdownViewModel? { get }
    var quizSubmissionBreakdownViewModel: TeacherQuizSubmissionBreakdownViewModelLive? { get }
    var assignmentDateSectionViewModel: AssignmentDateSectionViewModel? { get }
    var quizDateSectionViewModel: TeacherQuizDateSectionViewModelLive? { get }
    var attributes: [TeacherQuizAttribute] { get }

    func viewDidAppear()
    func editTapped(router: Router, viewController: WeakViewController)
    func previewTapped(router: Router, viewController: WeakViewController)
}

public enum QuizDetailsViewModelState: Equatable {
    case loading
    case error
    case ready
}
