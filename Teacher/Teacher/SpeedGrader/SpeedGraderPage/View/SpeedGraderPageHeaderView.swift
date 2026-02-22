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
import Combine

struct SpeedGraderPageHeaderView: View {
    let assignment: Assignment
    let submission: Submission
    let isLandscapeLayout: Bool
    let gradeSavingStatePublisher: CurrentValueSubject<GradeSavingState, Never>
    let gradeSavingFailureTapped: () -> Void

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @ObservedObject var landscapeSplitLayoutViewModel: SpeedGraderPageLandscapeSplitLayoutViewModel
    @State private var profileHeight: CGFloat = 0
    @State private var gradeSavingState: GradeSavingState = .idle
    @StateObject internal var viewModel: SpeedGraderPageHeaderViewModel
    @AccessibilityFocusState private var isSavingIndicatorFocused: Bool

    init(
        assignment: Assignment,
        submission: Submission,
        isLandscapeLayout: Bool,
        landscapeSplitLayoutViewModel: SpeedGraderPageLandscapeSplitLayoutViewModel,
        gradeSavingState: CurrentValueSubject<GradeSavingState, Never>,
        gradeSavingFailureTapped: @escaping () -> Void
    ) {
        self.assignment = assignment
        self.submission = submission
        self.isLandscapeLayout = isLandscapeLayout
        self.landscapeSplitLayoutViewModel = landscapeSplitLayoutViewModel
        self.gradeSavingStatePublisher = gradeSavingState
        self.gradeSavingFailureTapped = gradeSavingFailureTapped

        _gradeSavingState = .init(initialValue: gradeSavingState.value)
        _viewModel = StateObject(wrappedValue: SpeedGraderPageHeaderViewModel(assignment: assignment, submission: submission))
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: navigateToSubmitter) {
                HStack(spacing: 12) {
                    avatar

                    VStack(alignment: .leading, spacing: 2) {
                        nameText

                        ViewThatFits(in: .horizontal) {
                            InstUI.JoinedSubtitleLabels(
                                label1: { status },
                                label2: { dueText },
                                alignment: .top
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                status
                                dueText
                            }
                        }
                    }
                }
                .paddingStyle(.leading, .cellIconLeading)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .onSizeChange { size in
                if profileHeight != size.height {
                    profileHeight = size.height
                }
            }
            .identifier("SpeedGrader.userButton")

            gradeSavingStateView
                .accessibilityFocused($isSavingIndicatorFocused)

            if isLandscapeLayout {
                resizeDragger
            }
        }
        .onReceive(
            gradeSavingStatePublisher
                .debounce(for: 0.3, scheduler: DispatchQueue.main)
        ) { state in
            withAnimation {
                gradeSavingState = state
            }
            isSavingIndicatorFocused = state != .idle
        }
    }

    private var avatar: some View {
        Avatar(model: viewModel.userNameModel, size: 32)
    }

    private var nameText: some View {
        return Text(viewModel.userNameModel.name)
            .font(.semibold16)
            .foregroundStyle(.textDarkest)
    }

    private var status: some View {
        SubmissionStatusLabel(model: viewModel.submissionStatus)
    }

    private var dueText: some View {
        Text(submission.dueText)
            .font(.regular14)
            .foregroundStyle(.textDark)
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

    @ViewBuilder
    private var gradeSavingStateView: some View {
        let trailingPadding: InstUI.Styles.Padding = isLandscapeLayout ? .zero : .standard

        switch gradeSavingState {
        case .saving:

            HStack(spacing: 4) {
                Text("Saving", bundle: .teacher)
                    .font(.regular14)
                    .foregroundStyle(.textDark)
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .paddingStyle(.trailing, trailingPadding)
            .transition(.opacity)

        case .saved:

            Text("Saved", bundle: .teacher)
                .font(.regular14)
                .foregroundStyle(.textSuccess)
                .paddingStyle(.trailing, trailingPadding)
                .transition(.opacity)

        case .failure:
            Button(action: gradeSavingFailureTapped) {

                HStack(spacing: 4) {
                    Text("Failed", bundle: .teacher)
                        .font(.regular14)
                        .foregroundStyle(.textDark)
                    Image.infoSolid
                        .scaledIcon(size: 16)
                        .foregroundStyle(.textInfo)
                }
                .paddingStyle(.vertical, .cellTop)
                .paddingStyle(.leading, .standard)
                .paddingStyle(.trailing, trailingPadding)
            }
            .contentShape(Rectangle())
            .transition(.opacity)
        case .idle:
            SwiftUI.EmptyView()
        }
    }
}

#if DEBUG

#Preview {
    let testData = SpeedGraderAssembly.testData()
    SpeedGraderPageHeaderView(
        assignment: testData.assignment,
        submission: testData.submissions[0],
        isLandscapeLayout: false,
        landscapeSplitLayoutViewModel: SpeedGraderPageLandscapeSplitLayoutViewModel(),
        gradeSavingState: .init(.saving),
        gradeSavingFailureTapped: {}
    )
}

#endif
