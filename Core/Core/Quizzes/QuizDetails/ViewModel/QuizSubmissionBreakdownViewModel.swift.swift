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

public class QuizSubmissionBreakdownViewModel: SubmissionBreakdownViewModel {

    @Published public var isReady: Bool = false
    public var graded: Int = 0
    public var ungraded: Int = 0
    public var unsubmitted: Int = 0
    public var submissionCount: Int = 0
    public var noSubmissionTypes = false
    public var paperSubmissionTypes = false

    private let quizID: String
    private let courseID: String
    private var summary: Store<GetSubmissionSummary>

    private var submissionsPath: String { "courses/\(courseID)/quizzes/\(quizID)/submissions"
    }

    init(courseID: String, quizID: String) {
        self.quizID = quizID
        self.courseID = courseID
        summary = AppEnvironment.shared.subscribe(GetSubmissionSummary(
            context: .course(courseID),
            assignmentID: quizID
        ))
    }

    public func viewDidAppear() {
        summary.eventHandler = update
        summary.refresh(force: true)
    }
    public func routeToAll(router: Router, viewController: WeakViewController) {
        router.route(to: submissionsPath, from: viewController)
    }

    public func routeToGraded(router: Router, viewController: WeakViewController) {
        router.route(to: "\(submissionsPath)?filter=graded", from: viewController)
    }

    public func routeToUngraded(router: Router, viewController: WeakViewController) {
        router.route(to: "\(submissionsPath)?filter=needs_grading", from: viewController)
    }

    public func routeToUnsubmitted(router: Router, viewController: WeakViewController) {
        router.route(to: "\(submissionsPath)?filter=not_submitted", from: viewController)
    }

    private func update() {
        graded = summary.first?.graded ?? 0
        ungraded = summary.first?.ungraded ?? 0
        unsubmitted = summary.first?.unsubmitted ?? 0
        submissionCount = summary.first?.submissionCount ?? 0
        isReady = true
    }

}
