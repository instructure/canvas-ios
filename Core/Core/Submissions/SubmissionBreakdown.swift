//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct SubmissionBreakdown: View {
    let assignmentID: String
    let courseID: String
    let submissionTypes: [SubmissionType]

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var summary: Store<GetSubmissionSummary>

    @State var graded = 0
    @State var ungraded = 0
    @State var unsubmitted = 0
    @State var submissionCount = 0

    init(courseID: String, assignmentID: String, submissionTypes: [SubmissionType]) {
        self.assignmentID = assignmentID
        self.courseID = courseID
        self.submissionTypes = submissionTypes
        summary = AppEnvironment.shared.subscribe(GetSubmissionSummary(
            context: .course(courseID),
            assignmentID: assignmentID
        ))
    }

    var body: some View {
        Button(action: routeToAll, label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Submissions", bundle: .core)
                            .font(.medium16).foregroundColor(.textDark)
                        Spacer()
                    }
                    if submissionTypes.contains(.not_graded) || submissionTypes.contains(.none) {
                        Text("Tap to view submissions list.")
                            .font(.regular16).foregroundColor(.textDarkest)
                    } else if submissionTypes.contains(.on_paper) {
                        HStack(alignment: .top, spacing: 0) {
                            Graph(
                                action: routeToGraded,
                                label: Text("Graded", bundle: .core),
                                count: graded,
                                total: submissionCount
                            )
                            Text(String.localizedStringWithFormat(
                                NSLocalizedString("there_are_d_assignees_without_grades", comment: ""),
                                ungraded + unsubmitted
                            ))
                                .font(.regular14).foregroundColor(.textDarkest)
                                .padding(.leading, 22)
                            Spacer()
                        }
                    } else {
                        HStack(alignment: .top, spacing: 0) {
                            Graph(
                                action: routeToGraded,
                                label: Text("Graded", bundle: .core),
                                count: graded,
                                total: submissionCount
                            )
                                .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUngraded,
                                label: Text("Needs Grading", bundle: .core),
                                count: ungraded,
                                total: submissionCount
                            )
                                .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUnsubmitted,
                                label: Text("Not Submitted", bundle: .core),
                                count: unsubmitted,
                                total: submissionCount
                            )
                                .frame(maxWidth: .infinity)
                        }
                            .frame(maxWidth: 400)
                    }
                }
                    .padding(16)
                DisclosureIndicator().padding(.trailing, 16)
            }
                // Fix tapping in whitespace, without covering divider in DiscussionDetails
                .background(Color.backgroundLightest.padding(.bottom, 1))
        })
            .buttonStyle(ScaleButtonStyle(scale: 1))
            .accessibility(label: Text("View all submissions", bundle: .core))
            .identifier("AssignmentDetails.viewAllSubmissionsButton")
            .onAppear {
                summary.eventHandler = update
                summary.refresh(force: true)
            }
    }

    func update() {
        withAnimation(Animation.easeOut(duration: 0.5).delay(0.2)) {
            graded = summary.first?.graded ?? 0
            ungraded = summary.first?.ungraded ?? 0
            unsubmitted = summary.first?.unsubmitted ?? 0
            submissionCount = summary.first?.submissionCount ?? 0
        }
    }

    struct Graph: View {
        let action: () -> Void
        let label: Text
        let count: Int
        let total: Int

        var body: some View {
            Button(action: action, label: {
                VStack(spacing: 8) {
                    ProgressView(value: total == 0 ? 0 : CGFloat(count) / CGFloat(total))
                        .progressViewStyle(
                            .determinateCircle(
                                size: 70,
                                lineWidth: 7)
                        )
                        .modifier(Counter(count: Double(count)))
                        .padding(.horizontal, 10).padding(.top, 4)
                    label
                        .font(.medium12).foregroundColor(.textDarkest)
                }
            })
                .buttonStyle(ScaleButtonStyle(scale: 0.95))
        }
    }

    struct Counter: AnimatableModifier {
        var count: Double = 0

        var animatableData: Double {
            get { count }
            set { count = newValue }
        }

        func body(content: Content) -> some View {
            content.overlay(
                Text(floor(count))
                    .font(.medium16).foregroundColor(.textDarkest)
            )
        }
    }

    var submissionsPath: String { "courses/\(courseID)/assignments/\(assignmentID)/submissions" }

    func routeToAll() {
        env.router.route(to: submissionsPath, from: controller)
    }

    func routeToGraded() {
        env.router.route(to: "\(submissionsPath)?filter=graded", from: controller)
    }

    func routeToUngraded() {
        env.router.route(to: "\(submissionsPath)?filter=needs_grading", from: controller)
    }

    func routeToUnsubmitted() {
        env.router.route(to: "\(submissionsPath)?filter=not_submitted", from: controller)
    }
}
