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
import Core

struct SubmissionHeaderView: View {
    let assignment: Assignment
    let submission: Submission
    let isLandscapeLayout: Bool

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @ObservedObject var landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel
    @State private var profileHeight: CGFloat = 0
    @StateObject internal var viewModel: SubmissionHeaderViewModel

    init(
        assignment: Assignment,
        submission: Submission,
        isLandscapeLayout: Bool,
        landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel
    ) {
        self.assignment = assignment
        self.submission = submission
        self.isLandscapeLayout = isLandscapeLayout
        self.landscapeSplitLayoutViewModel = landscapeSplitLayoutViewModel
        _viewModel = StateObject(wrappedValue: SubmissionHeaderViewModel(assignment: assignment, submission: submission))
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: navigateToSubmitter) {
                HStack(spacing: 12) {
                    avatar

                    VStack(alignment: .leading, spacing: 2) {
                        nameText

                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .top, spacing: 4) {
                                status
                                statusDueTextDivider
                                dueText
                            }
                            .fixedSize(horizontal: false, vertical: true)

                            VStack(alignment: .leading, spacing: 2) {
                                status
                                dueText
                            }
                        }
                    }
                }
                .paddingStyle(.leading, .cellIconLeading)
                .paddingStyle(.trailing, .standard)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onSizeChange { size in
                if profileHeight != size.height {
                    profileHeight = size.height
                }
            }
            .identifier("SpeedGrader.userButton")

            if isLandscapeLayout {
                resizeDragger
            }
        }
    }

    @ViewBuilder
    private var avatar: some View {
        let size: CGFloat = 32

        if assignment.anonymizeStudents {
            Avatar.Anonymous(isGroup: viewModel.isGroupSubmission, size: size)
        } else if viewModel.isGroupSubmission {
            Avatar.Anonymous(isGroup: true, size: size)
        } else {
            Avatar(name: submission.user?.name, url: submission.user?.avatarURL, size: size)
        }
    }

    private var nameText: some View {
        let name: Text
        if assignment.anonymizeStudents {
            name = viewModel.isGroupSubmission ? Text("Group", bundle: .teacher) : Text("Student", bundle: .teacher)
        } else {
            name = Text(viewModel.submitterName)
        }

        return name
            .font(.semibold16)
            .foregroundStyle(.textDarkest)
    }

    private var status: some View {
        HStack(spacing: 2) {
            Image(uiImage: submission.status.icon)
                .scaledIcon(size: 16)
            Text(submission.status.text)
                .font(.regular14)
        }
        .foregroundStyle(Color(submission.status.color))
    }

    private var dueText: some View {
        Text(assignment.dueText)
            .font(.regular14)
            .foregroundStyle(.textDark)
    }

    private var statusDueTextDivider: some View {
        Color.borderMedium
            .frame(width: 1)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }

    private func navigateToSubmitter() {
        guard !assignment.anonymizeStudents, let routeToSubmitter = viewModel.routeToSubmitter else { return }

        env.router.route(
            to: routeToSubmitter,
            userInfo: ["courseID": assignment.courseID, "navigatorOptions": ["modal": true]],
            from: controller,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }

    private var resizeDragger: some View {
        Image.moveEndLine
            .scaledIcon()
            .rotationEffect(landscapeSplitLayoutViewModel.dragIconRotation)
            .paddingStyle(.horizontal, .standard)
            .frame(maxHeight: profileHeight)
            .contentShape(Rectangle())
            .gesture(resizeGesture)
            .onTapGesture {
                landscapeSplitLayoutViewModel.didTapDragIcon()
            }
            .accessibilityLabel(Text("Drawer menu", bundle: .teacher))
            .accessibilityHint(landscapeSplitLayoutViewModel.dragIconA11yHint)
            .accessibilityValue(landscapeSplitLayoutViewModel.dragIconA11yValue)
            .accessibilityAddTraits(.isButton)
            .accessibilityRemoveTraits(.isImage)
            .accessibility(identifier: "SpeedGrader.fullScreenToggleInLandscape")
    }

    private var resizeGesture: some Gesture {
        DragGesture(
            minimumDistance: 10,
            coordinateSpace: .global
        )
        .onChanged { value in
            let translation = value.translation.width
            landscapeSplitLayoutViewModel.didUpdateDragGesturePosition(horizontalTranslation: translation)
        }
        .onEnded { _ in
            landscapeSplitLayoutViewModel.didEndDragGesture()
        }
    }
}

#if DEBUG

#Preview {
    let testData = SpeedGraderAssembly.testData()
    SubmissionHeaderView(
        assignment: testData.assignment,
        submission: testData.submissions[0],
        isLandscapeLayout: true,
        landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel()
    )
}

#endif
