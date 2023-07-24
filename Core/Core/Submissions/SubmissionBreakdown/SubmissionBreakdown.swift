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

struct SubmissionBreakdown<ViewModel: SubmissionBreakdownViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        Button(action: routeToAll, label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Submissions", bundle: .core)
                            .font(.medium16).foregroundColor(.textDark)
                        Spacer()
                    }
                    if viewModel.noSubmissionTypes {
                        Text("Tap to view submissions list.")
                            .font(.regular16).foregroundColor(.textDarkest)
                    } else if viewModel.paperSubmissionTypes {
                        HStack(alignment: .top, spacing: 0) {
                            Graph(
                                action: routeToGraded,
                                label: Text("Graded", bundle: .core),
                                count: viewModel.graded,
                                total: viewModel.submissionCount
                            )
                            Text(String.localizedStringWithFormat(
                                NSLocalizedString("there_are_d_assignees_without_grades", comment: ""),
                                viewModel.ungraded + viewModel.unsubmitted
                            ))
                                .font(.regular14).foregroundColor(.textDarkest)
                                .padding(.leading, 22)
                            Spacer()
                        }
                    } else if viewModel.noGradingNeeded {
                        HStack(alignment: .top, spacing: 0) {
                            Graph(
                                action: routeToGraded,
                                label: Text("Submitted", bundle: .core),
                                count: viewModel.graded,
                                total: viewModel.submissionCount
                            )
                            .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUnsubmitted,
                                label: Text("Not Submitted", bundle: .core),
                                count: viewModel.unsubmitted,
                                total: viewModel.submissionCount
                            )
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        HStack(alignment: .top, spacing: 0) {
                            Graph(
                                action: routeToGraded,
                                label: Text("Graded", bundle: .core),
                                count: viewModel.graded,
                                total: viewModel.submissionCount
                            )
                                .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUngraded,
                                label: Text("Needs Grading", bundle: .core),
                                count: viewModel.ungraded,
                                total: viewModel.submissionCount
                            )
                                .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUnsubmitted,
                                label: Text("Not Submitted", bundle: .core),
                                count: viewModel.unsubmitted,
                                total: viewModel.submissionCount
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
                viewModel.viewDidAppear()
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
                        .animation(Animation.easeOut(duration: 0.5).delay(0.2), value: count)
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

    func routeToAll() {
        viewModel.routeToAll(router: env.router, viewController: controller)
    }

    func routeToGraded() {
        viewModel.routeToGraded(router: env.router, viewController: controller)
    }

    func routeToUngraded() {
        viewModel.routeToUngraded(router: env.router, viewController: controller)
    }

    func routeToUnsubmitted() {
        viewModel.routeToUnsubmitted(router: env.router, viewController: controller)
    }
}

#if DEBUG

struct SubmissionBreakdown_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PreviewSubmissionBreakdownViewModel(graded: 1, ungraded: 2, unsubmitted: 3, submissionCount: 6)

        SubmissionBreakdown(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        SubmissionBreakdown(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}

#endif
