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
        case error
        case ready
    }

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @Published public private(set) var state: ViewModelState = .loading
    public var assignment: Assignment?
    public let courseID: String

    //Quiz attributes
    @Published public var title: String = ""

    private let quizID: String
    private var assignmentID: String?
    private var quiz: Quiz?

    public init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
        fetchQuiz()
    }

    func fetchQuiz() {
        let useCase = GetQuiz(courseID: courseID, quizID: quizID)
        useCase.fetch(force: true) { [weak self] _, _, fetchError in
            guard let self = self else { return }
            self.quiz = self.env.database.viewContext.fetch(scope: useCase.scope).first
            self.assignmentID = self.quiz?.assignmentID
            //alert = fetchError.map { .error($0) }
            self.fetchAssignment()
        }
    }

    func fetchAssignment() {
        guard let assignmentID = assignmentID else { return }
        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [ .overrides ])
        useCase.fetch(force: true) { [weak self] _, _, fetchError in
            guard let self = self else { return }

            self.assignment = self.env.database.viewContext.fetch(scope: useCase.scope).first
            /*
            canUnpublish = assignment?.canUnpublish == true
            description = assignment?.details ?? ""
            gradingType = assignment?.gradingType ?? .points
            title = assignment?.name ?? ""
            overrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) } ?? []
            pointsPossible = assignment?.pointsPossible
            published = assignment?.published == true

             if let quiz = quiz, let assignment = assignment {
                 quizAttributes = QuizAttributes(quiz: quiz, assignment: assignment)
             }
*/
            self.title = self.assignment?.name ?? ""


            self.state = .ready
            //alert = fetchError.map { .error($0) }
        }
    }
}
