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

    func launchLTITool(router: Router, viewController: WeakViewController) {
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
