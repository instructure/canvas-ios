//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct RedesignedSubmissionBreakdownView<ViewModel: SubmissionBreakdownViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        Button(action: routeToAll, label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Submissions", bundle: .core)
                            .font(.semibold16)
                            .foregroundColor(.textDarkest)
                        Spacer()
                        if !viewModel.noSubmissionTypes {
                            Button(
                                action: routeToAll, label: {
                                    HStack(spacing: 5) {
                                        Text("All")
                                        InstUI.DisclosureIndicator()
                                    }
                                }
                            )
                            .font(.regular16)
                            .tint(viewModel.color)
                        }
                    }
                    Spacer().frame(height: 20)
                    if viewModel.noSubmissionTypes {
                        HStack {
                            Text("Tap to view submissions list.", bundle: .core)
                                .font(.regular16)
                                .foregroundColor(.textDarkest)
                            Spacer()
                            InstUI.DisclosureIndicator()
                        }
                    } else if viewModel.paperSubmissionTypes {
                        HStack(alignment: .top, spacing: 0) {
                            Graph(
                                action: routeToGraded,
                                label: Text("Graded", bundle: .core),
                                count: viewModel.graded,
                                total: viewModel.submissionCount,
                                color: viewModel.color
                            )
                            Text(String.localizedStringWithFormat(
                                String(localized: "there_are_d_assignees_without_grades", bundle: .core),
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
                                total: viewModel.submissionCount,
                                color: viewModel.color
                            )
                            .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUnsubmitted,
                                label: Text("Not Submitted", bundle: .core),
                                count: viewModel.unsubmitted,
                                total: viewModel.submissionCount,
                                color: viewModel.color
                            )
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        HStack(alignment: .top, spacing: 0) {
                            Graph(
                                action: routeToGraded,
                                label: Text("Graded", bundle: .core),
                                count: viewModel.graded,
                                total: viewModel.submissionCount,
                                color: viewModel.color
                            )
                                .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUngraded,
                                label: Text("Needs Grading", bundle: .core),
                                count: viewModel.ungraded,
                                total: viewModel.submissionCount,
                                color: viewModel.color
                            )
                                .frame(maxWidth: .infinity)
                            Graph(
                                action: routeToUnsubmitted,
                                label: Text("Not Submitted", bundle: .core),
                                count: viewModel.unsubmitted,
                                total: viewModel.submissionCount,
                                color: viewModel.color
                            )
                                .frame(maxWidth: .infinity)
                        }
                            .frame(maxWidth: 400)
                    }
                    Spacer().frame(height: 16)
                }
                .padding(16)
                .background(Color.backgroundLightest)
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.08), radius: 2, y: 2)
                .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
                .padding(16)
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
        let color: Color

        var body: some View {
            Button(action: action, label: {
                VStack(spacing: 12) {
                    ProgressView(value: total == 0 ? 0 : CGFloat(count) / CGFloat(total))
                        .progressViewStyle(
                            .determinateCircle(
                                size: 80,
                                lineWidth: 2,
                                color: color
                            )
                        )
                        .modifier(Counter(count: Double(count)))
                        .padding(.horizontal, 10).padding(.top, 4)
                        .animation(Animation.easeOut(duration: 0.5).delay(0.2), value: count)
                    label
                        .font(.regular12).foregroundColor(.textDark)
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
                    .font(.regular22).foregroundColor(.textDarkest)
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

struct RedesignedSubmissionBreakdown_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PreviewSubmissionBreakdownViewModel(graded: 1, ungraded: 2, unsubmitted: 3, submissionCount: 6)

        RedesignedSubmissionBreakdownView(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        RedesignedSubmissionBreakdownView(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}

#endif
