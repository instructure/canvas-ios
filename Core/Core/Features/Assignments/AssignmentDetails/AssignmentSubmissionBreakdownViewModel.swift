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

public class AssignmentSubmissionBreakdownViewModel: SubmissionBreakdownViewModelProtocol {

    @Published public var isReady: Bool = false
    @Published public var graded: Int = 0
    @Published public var ungraded: Int = 0
    @Published public var unsubmitted: Int = 0
    @Published public var submissionCount: Int = 0
    public var noGradingNeeded: Bool = false

    public var noSubmissionTypes: Bool {
        submissionTypes.contains(.not_graded) || submissionTypes.contains(.none)
    }

    public var paperSubmissionTypes: Bool {
        submissionTypes.contains(.on_paper)
    }

    public private(set) var color: Color = .accentColor

    private let env: AppEnvironment
    private let assignmentID: String
    private let courseID: String
    private let submissionTypes: [SubmissionType]
    private var summary: Store<GetSubmissionSummary>
    private var submissionsPath: String { "/courses/\(courseID)/assignments/\(assignmentID)/submissions" }

    public init(courseID: String, assignmentID: String, submissionTypes: [SubmissionType], color: UIColor? = nil, env: AppEnvironment) {
        self.assignmentID = assignmentID
        self.courseID = courseID
        self.submissionTypes = submissionTypes
        self.color = color?.asColor ?? .accentColor
        self.env = env

        summary = env.subscribe(GetSubmissionSummary(
            context: .course(courseID),
            assignmentID: assignmentID
        ))
    }

    public func viewDidAppear() {
        summary.eventHandler = { [weak self] in
            self?.update()
        }
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
        let customUnsubmitted = customGradeStatedCount(for: .unsubmitted)
        let customSubmitted = customGradeStatedCount(
            noScoreChecked: true,
            for: .submitted, .pending_review, .graded
        )

        let summaryValues = self.summary.first

        graded = (summaryValues?.graded ?? 0) + customSubmitted + customUnsubmitted
        ungraded = max((summaryValues?.ungraded ?? 0) - customSubmitted, 0)
        unsubmitted = max((summaryValues?.unsubmitted ?? 0) - customUnsubmitted, 0)

        submissionCount = summaryValues?.submissionCount ?? 0
        isReady = true
    }

    /// This is used because of a limitation on API for **`GetSubmissionSummary`**, by
    /// which submissions of custom grade status is not being counted for **`graded`**
    /// when workflow state equals to `unsubmitted` or `submitted`
    private func customGradeStatedCount(
        noScoreChecked: Bool = false,
        for state: SubmissionWorkflowState...
    ) -> Int {
        return env
            .database
            .viewContext
            .submissionsCountOfCustomGradeStatus(
                forAssignment: assignmentID,
                invalidScoreChecked: noScoreChecked,
                atStates: state
            )
    }
}
