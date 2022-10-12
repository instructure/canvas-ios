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

public class QuizSubmissionBreakdownViewModel: SubmissionBreakdownViewModelProtocol {

    @Published public var isReady: Bool = false
    @Published public var showError: Bool = false
    @Published public private(set) var errorText: String?
    @Published public var graded: Int = 0
    @Published public var ungraded: Int = 0
    @Published public var unsubmitted: Int = 0
    @Published public var submissionCount: Int = 0

    public var noSubmissionTypes = false
    public var paperSubmissionTypes = false

    private let quizID: String
    private let courseID: String
    private var submissions: Store<GetAllQuizSubmissions>
    private var enrollments: Store<GetEnrollments>

    init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
        submissions = AppEnvironment.shared.subscribe(GetAllQuizSubmissions(
            courseID: courseID,
            quizID: quizID))

        enrollments = AppEnvironment.shared.subscribe(GetEnrollments(
            context: .course(courseID),
            types: [ "StudentEnrollment" ]))
    }

    public func viewDidAppear() {
        submissions.eventHandler = { [weak self] in
            self?.didUpdate()
        }
        submissions.exhaust(force: true)
        enrollments.eventHandler = { [weak self] in
            self?.didUpdate()
        }
        enrollments.exhaust(force: true)
    }

    public func routeToAll(router: Router, viewController: WeakViewController) {
        showPracticeError()
    }

    public func routeToGraded(router: Router, viewController: WeakViewController) {
        showPracticeError()
    }

    public func routeToUngraded(router: Router, viewController: WeakViewController) {
        showPracticeError()
    }

    public func routeToUnsubmitted(router: Router, viewController: WeakViewController) {
        showPracticeError()
    }

    private func showPracticeError() {
        showError = true
        errorText = NSLocalizedString("Practice quizzes & surveys do not have detail views.", comment: "")
    }

    private func didUpdate() {
        if submissions.requested, submissions.pending, submissions.hasNextPage, enrollments.requested, enrollments.pending, enrollments.hasNextPage { return }
        submissionCount = enrollments.count
        graded = submissions.filter { $0.workflowState == .complete }.count
        ungraded = submissions.filter { $0.workflowState == .pending_review }.count
        unsubmitted = submissionCount - (graded + ungraded)
        isReady = true
    }
}
