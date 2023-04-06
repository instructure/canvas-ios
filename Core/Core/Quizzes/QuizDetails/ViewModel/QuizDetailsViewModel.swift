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

public class QuizDetailsViewModel: QuizDetailsViewModelProtocol {
    @Published public private(set) var state: QuizDetailsViewModelState = .loading

    public private(set) var courseColor: UIColor?
    public var title: String { NSLocalizedString("Quiz Details", comment: "") }
    public var subtitle: String { courseUseCase.first?.name ?? "" }
    public var showSubmissions: Bool { courseUseCase.first?.enrollments?.contains(where: { $0.isTeacher || $0.isTA }) == true }
    public private(set) var assignmentSubmissionBreakdownViewModel: AssignmentSubmissionBreakdownViewModel?
    public private(set) var quizSubmissionBreakdownViewModel: QuizSubmissionBreakdownViewModel?
    public private(set) var assignmentDateSectionViewModel: AssignmentDateSectionViewModel?
    public private(set) var quizDateSectionViewModel: QuizDateSectionViewModel?

    public var quizTitle: String { quiz?.title ?? "" }
    public var pointsPossibleText: String { quiz?.pointsPossibleText ?? "" }
    public var published: Bool { quiz?.published ?? false }
    public var quizDetailsHTML: String? { quiz?.details }
    public var attributes: [QuizAttribute] {
        guard let quiz = quiz else { return [] }
        return QuizAttributes(quiz: quiz, assignment: assignment).attributes
    }

    @Published private var quiz: Quiz?
    @Published private var assignment: Assignment?
    @Published private var course: Course?

    private let env = AppEnvironment.shared
    private let quizID: String
    private let courseID: String
    private var refreshCompletion: (() -> Void)?
    private lazy var courseUseCase = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    private lazy var quizUseCase = env.subscribe(GetQuiz(courseID: courseID, quizID: quizID)) { [weak self] in
        self?.didUpdate()
    }

    private lazy var assignmentsUseCase = env.subscribe(GetAssignmentsByGroup(courseID: courseID)) { [weak self] in
        self?.didUpdate()
    }

    // MARK: - Public Interface -

    public init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
    }

    public func viewDidAppear() {
        quizUseCase.refresh(force: true)
        assignmentsUseCase.refresh(force: true)
        courseUseCase.refresh()
    }

    public func editTapped(router: Router, viewController: WeakViewController) {
        router.route(
            to: "courses/\(courseID)/quizzes/\(quizID)/edit",
            from: viewController,
            options: .modal(isDismissable: false, embedInNav: true)
        )
    }

    public func previewTapped(router: Router, viewController: WeakViewController) {
        router.route(
            to: "courses/\(courseID)/quizzes/\(quizID)/preview",
            from: viewController,
            options: .modal(.fullScreen, isDismissable: false, embedInNav: true, addDoneButton: true)
        )
    }

    // MARK: - Refreshable protocol

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        return await withCheckedContinuation { continuation in
            refreshCompletion = {
                continuation.resume()
            }
            quizUseCase.refresh(force: true)
            assignmentsUseCase.refresh(force: true)
        }
    }

    // MARK: - Private functions

    private func courseDidUpdate() {
        self.course = course
        courseColor = courseUseCase.first?.color
    }

    private func didUpdate() {
        if quizUseCase.requested, quizUseCase.pending, assignmentsUseCase.requested, assignmentsUseCase.pending, assignmentsUseCase.hasNextPage { return }
        if let quiz = quizUseCase.first {
            self.quiz = quiz
            if let assignmentID = quiz.assignmentID, let assignment = assignmentsUseCase.first(where: { $0.id == assignmentID }) {
                self.assignment = assignment
                assignmentDateSectionViewModel = AssignmentDateSectionViewModel(assignment: assignment)
                assignmentSubmissionBreakdownViewModel = AssignmentSubmissionBreakdownViewModel(courseID: courseID, assignmentID: assignmentID, submissionTypes: assignment.submissionTypes)
            } else {
                quizSubmissionBreakdownViewModel = QuizSubmissionBreakdownViewModel(courseID: courseID, quizID: quizID)
                quizDateSectionViewModel = QuizDateSectionViewModel(quiz: quiz)
            }
            state = .ready
        } else {
            state = .error
        }
        finishRefresh()
    }

    private func finishRefresh() {
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}
