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

    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case error
        case data(T)
    }

    @Environment(\.appEnvironment) private var env
    @Published public private(set) var state: ViewModelState<Quiz> = .loading
    @Published public private(set) var courseColor: UIColor?

    public var title: String { NSLocalizedString("Quiz Details", comment: "") }
    public var subtitle: String { course.first?.name ?? "" }
    public var showSubmissions: Bool { course.first?.enrollments?.contains(where: { $0.isTeacher || $0.isTA }) == true }
    public var assignmentSubmissionBreakdownViewModel: AssignmentSubmissionBreakdownViewModel?
    public var quizSubmissionBreakdownViewModel: QuizSubmissionBreakdownViewModel?
    public var assignmentDateSectionViewModel: AssignmentDateSectionViewModel?
    public var quizDateSectionViewModel: QuizDateSectionViewModel?

    private let quizID: String
    private let courseID: String
    private var assignment: Assignment?
    private var refreshCompletion: (() -> Void)?
    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    private lazy var quiz = env.subscribe(GetQuiz(courseID: courseID, quizID: quizID)) { [weak self] in
        self?.didUpdate()
    }

    private lazy var assignments = env.subscribe(GetAssignmentsByGroup(courseID: courseID)) { [weak self] in
        self?.didUpdate()
    }

    // MARK: - Public Interface -

    public init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
    }

    public func viewDidAppear() {
        quiz.refresh(force: true)
        assignments.refresh(force: true)
        course.refresh()
    }

    public func editTapped(router: Router, viewController: WeakViewController) {
        env.router.route(
            to: "courses/\(courseID)/quizzes/\(quizID)/edit",
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

    // MARK: - Private functions

    public var attributes: [QuizAttribute] {
        guard let quiz = quiz.first else { return [] }
        return QuizAttributes(quiz: quiz, assignment: assignment).attributes
    }

    private func courseDidUpdate() {
        courseColor = course.first?.color
    }

    private func didUpdate() {
        if quiz.requested, quiz.pending, assignments.requested, assignments.pending, assignments.hasNextPage { return }
        finishRefresh()
        if let quiz = quiz.first {
            if let assignmentID = quiz.assignmentID, let assignment = assignments.first(where: { $0.id == assignmentID }) {
                self.assignment = assignment
                assignmentDateSectionViewModel = AssignmentDateSectionViewModel(assignment: assignment)
                assignmentSubmissionBreakdownViewModel = AssignmentSubmissionBreakdownViewModel(courseID: courseID, assignmentID: assignmentID, submissionTypes: assignment.submissionTypes)
            } else {
                quizSubmissionBreakdownViewModel = QuizSubmissionBreakdownViewModel(courseID: courseID, quizID: quizID)
                quizDateSectionViewModel = QuizDateSectionViewModel(quiz: quiz)
            }
            state = .data(quiz)
        } else {
            state = .error
        }
    }

    private func finishRefresh() {
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

extension QuizDetailsViewModel: Refreshable {
    public func refresh(completion: @escaping () -> Void) {
        refreshCompletion = completion
        quiz.refresh(force: true)
        assignments.refresh(force: true)
    }
}
