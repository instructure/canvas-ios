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

#if DEBUG
/**
Use only for SwiftUI previews.
*/
public class QuizDetailsViewModelPreview: QuizDetailsViewModelProtocol {
    public var state: QuizDetailsViewModelState
    public var courseColor: UIColor?
    public var title: String
    public var subtitle: String
    public var showSubmissions: Bool
    public var quizTitle: String
    public var pointsPossibleText: String
    public var published: Bool
    public var quizDetailsHTML: String?
    public var assignmentSubmissionBreakdownViewModel: AssignmentSubmissionBreakdownViewModel?
    public var quizSubmissionBreakdownViewModel: QuizSubmissionBreakdownViewModel?
    public var assignmentDateSectionViewModel: AssignmentDateSectionViewModel?
    public var quizDateSectionViewModel: QuizDateSectionViewModel?
    public var attributes: [QuizAttribute]

    public init(
        state: QuizDetailsViewModelState,
        courseColor: UIColor,
        title: String,
        subtitle: String,
        quizTitle: String,
        pointsPossibleText: String,
        published: Bool,
        quizDetailsHTML: String,
        attributes: [QuizAttribute]
    ) {
        self.state = state
        self.courseColor = courseColor
        self.title = title
        self.subtitle = subtitle
        self.showSubmissions = false
        self.quizTitle = quizTitle
        self.pointsPossibleText = pointsPossibleText
        self.published = published
        self.quizDetailsHTML = quizDetailsHTML
        self.attributes = attributes
    }

    public func viewDidAppear() {}
    public func editTapped(router: Router, viewController: WeakViewController) {}
    public func previewTapped(router: Router, viewController: WeakViewController) {}
    public func refresh() async {}
    public func refresh(completion: @escaping () -> Void) {}
}
#endif
