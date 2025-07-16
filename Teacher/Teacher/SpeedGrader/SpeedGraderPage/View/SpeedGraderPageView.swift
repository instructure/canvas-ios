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

import Core
import SwiftUI
import Combine

/// A SpeedGrader page representing a student's submission.
/// It doesn't have a navigaton bar (it's parent `SpeedGraderScreen` handles it),
/// but has it's own header, split layout, drawer, etc.
/// - Note: Users navigate between SpeedGrader pages via horizontal swipes.
/// Make sure subviews don't interfere with this gesture.
struct SpeedGraderPageView: View {

    private enum Layout {
        case portrait
        case landscape // only on iPads no matter the iPhone screen size
    }

    @Environment(\.viewController) private var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The index used for paging
    let userIndexInSubmissionList: Int

    // MARK: - Tab & Drawer properties

    @State private var drawerState: DrawerState = .min
    @State private var selectedTab: SpeedGraderPageTab = .grades
    @AccessibilityFocusState private var a11yFocusedTab: SpeedGraderPageTab?

    // MARK: - Layout properties

    /// Used to match landscape drawer's segmented control height with the header height.
    @State private var headerHeight: CGFloat = 0

    /// Used to work around an issue which caused the page to re-load after putting the app into background. See `layoutForWidth()` method for more.
    @State private var lastPresentedLayout: Layout = .portrait

    /// We can't measure the view's size because when keyboard appears it shrinks it
    /// and that would cause the layout to switch from portrait to landscape. We use the
    /// navigation controller's view size instead to decide which layout to use.
    private var containerSize: CGSize {
        controller.value.navigationController?.view.frame.size ?? .zero
    }

    // MARK: - Misc properties

    @StateObject private var viewModel: SpeedGraderPageViewModel
    @ObservedObject private var landscapeSplitLayoutViewModel: SpeedGraderPageLandscapeSplitLayoutViewModel

    private let handleRefresh: (() -> Void)?

    // MARK: - Init

    init(
        env: AppEnvironment,
        userIndexInSubmissionList: Int,
        viewModel: SpeedGraderPageViewModel,
        landscapeSplitLayoutViewModel: SpeedGraderPageLandscapeSplitLayoutViewModel,
        handleRefresh: (() -> Void)?
    ) {
        self.userIndexInSubmissionList = userIndexInSubmissionList
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.landscapeSplitLayoutViewModel = landscapeSplitLayoutViewModel
        self.handleRefresh = handleRefresh
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let bottomInset = geometry.safeAreaInsets.bottom
            let minHeight = bottomInset + 87
            let maxHeight = bottomInset + geometry.size.height
            // At 1/4 of a screen offset, scale to 90% and round corners to 20
            let delta = abs(geometry.frame(in: .global).minX / max(1, geometry.size.width))
            let scale = interpolate(value: delta, fromMin: 0, fromMax: 0.25, toMin: 1, toMax: 0.9)
            let cornerRadius = interpolate(value: delta, fromMin: 0, fromMax: 0.25, toMin: 0, toMax: 20)

            mainLayout(
                bottomInset: bottomInset,
                minHeight: minHeight,
                maxHeight: maxHeight
            )
            .cornerRadius(cornerRadius)
            .scaleEffect(scale)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onSizeChange { newSize in
            // These conditions are to avoid reseting the landscape layout when the app is backgrounded or rotated to portrait.
            if layout(for: containerSize) == .landscape, UIApplication.shared.applicationState != .background {
                landscapeSplitLayoutViewModel.updateScreenWidth(newSize.width)
            }
        }
        .tint(viewModel.contextColor)
        .clipped()
    }

    @ViewBuilder
    private func mainLayout(
        bottomInset: CGFloat,
        minHeight: CGFloat,
        maxHeight: CGFloat
    ) -> some View {
        switch layout(for: containerSize) {
        case .landscape:
            landscapeLayout(bottomInset: bottomInset)
        case .portrait:
            portraitLayout(minHeight: minHeight, maxHeight: maxHeight, bottomInset: bottomInset)
        }
    }

    // MARK: - Landscape layout

    private func landscapeLayout(bottomInset: CGFloat) -> some View {
        HStack(spacing: 0) {
            landscapeLeftColumn(bottomInset: bottomInset)
                .frame(width: landscapeSplitLayoutViewModel.leftColumnWidth)

            InstUI.Divider()

            landscapeRightColumn(bottomInset: bottomInset)
                .frame(width: landscapeSplitLayoutViewModel.rightColumnWidth)
                .hidden(landscapeSplitLayoutViewModel.isRightColumnHidden)
        }
        .onAppear { didChangeLayout(to: .landscape) }
        .onChange(of: landscapeSplitLayoutViewModel.isRightColumnHidden) { _, isHidden in
            // Auto focus voiceover on the selected tab when the right column is shown
            if isHidden { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                a11yFocusedTab = selectedTab
            }
        }
    }

    private func landscapeLeftColumn(bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            headerView(isLandscapeLayout: true)
                .accessibility(sortPriority: 2)
                .onHeightChange(update: $headerHeight)

            InstUI.Divider()

            VStack(alignment: .leading, spacing: 0) {
                if viewModel.hasSubmissions {
                    attemptAndFilePickers
                    InstUI.Divider()
                }

                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        similarityScoreView
                        submissionViewer
                    }
                }
                Spacer().frame(height: bottomInset)
            }
            .zIndex(1)
            .accessibility(sortPriority: 1)
        }
    }

    private func landscapeRightColumn(bottomInset: CGFloat) -> some View {
        tabsView(bottomInset: bottomInset, tabsContainerType: .splitView)
    }

    // MARK: - Portrait layout

    private func portraitLayout(
        minHeight: CGFloat,
        maxHeight: CGFloat,
        bottomInset: CGFloat
    ) -> some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                headerView(isLandscapeLayout: false)

                InstUI.Divider()

                if viewModel.hasSubmissions {
                    attemptAndFilePickers
                        .accessibility(hidden: drawerState.isFullyOpen)
                    InstUI.Divider()
                }

                VStack(spacing: 0) {
                    similarityScoreView
                    submissionViewer
                }
                .accessibilityHidden(drawerState.isOpen)

                Spacer()
                    .frame(height: drawerState.isClosed ? minHeight : (minHeight + maxHeight) / 2)
            }

            DrawerContainer(
                state: $drawerState,
                minHeight: minHeight,
                maxHeight: maxHeight
            ) {
                tabsView(bottomInset: bottomInset, tabsContainerType: .drawer)
            }
            .accessibilityAddTraits(drawerState.isFullyOpen ? .isModal : [])
        }
        .onAppear { didChangeLayout(to: .portrait) }
    }

    // MARK: - Components

    private func headerView(isLandscapeLayout: Bool) -> some View {
        SpeedGraderPageHeaderView(
            assignment: viewModel.assignment,
            submission: viewModel.submission,
            isLandscapeLayout: isLandscapeLayout,
            landscapeSplitLayoutViewModel: landscapeSplitLayoutViewModel
        )
    }

    private var similarityScoreView: some View {
        SimilarityScoreView(viewModel.selectedAttempt, file: viewModel.selectedFile)
    }

    private var submissionViewer: some View {
        SubmissionViewer(
            assignment: viewModel.assignment,
            submission: viewModel.selectedAttempt,
            fileID: viewModel.selectedFile?.id,
            studentAnnotationViewModel: viewModel.studentAnnotationViewModel,
            handleRefresh: handleRefresh
        )
    }

    // MARK: - Attempt and File pickers

    private var attemptAndFilePickers: some View {
        HStack(alignment: .center, spacing: 12) {
            InstUI.PickerMenu(
                selectedId: Binding(
                    get: { viewModel.selectedAttemptNumber },
                    set: { attemptPickerDidSelect(index: $0) }
                ),
                allOptions: viewModel.attemptPickerOptions,
                label: {
                    pickerButton(
                        title: viewModel.selectedAttemptTitle,
                        icon: .resetHistoryLine,
                        count: nil, // not displaying count badge, partly to sidestep the issue of missing attempt numbers
                        truncationMode: .head
                    )
                }
            )
            .accessibilityShowsLargeContentViewer {
                Text(viewModel.selectedAttemptTitle)
            }

            if viewModel.hasMultipleFiles {
                InstUI.PickerMenu(
                    selectedId: Binding(
                        get: { viewModel.selectedFile?.id },
                        set: { filePickerDidSelect(id: $0) }
                    ),
                    allOptions: viewModel.filePickerOptions,
                    label: {
                        pickerButton(
                            title: viewModel.selectedFileName,
                            icon: .documentLine,
                            count: viewModel.filePickerOptions.count,
                            truncationMode: .tail
                        )
                    }
                )
                .accessibilityLabel(Text("File \(viewModel.selectedFileNumber) of \(viewModel.filePickerOptions.count)", bundle: .teacher, comment: "Example: File 1 of 2"))
                .accessibilityValue(viewModel.selectedFileName)
                .accessibilityShowsLargeContentViewer {
                    Text(viewModel.selectedFileName)
                }
            }
        }
        .paddingStyle(.horizontal, .standard)
        .padding(.vertical, 6)
    }

    private func attemptPickerDidSelect(index: Int) {
        withTransaction(.exclusive()) {
            viewModel.didSelectAttempt(attemptNumber: index)
        }
    }

    private func filePickerDidSelect(id: String?) {
        viewModel.didSelectFile(fileId: id)
        snapDrawer(to: .min)
    }

    private func pickerButton(title: String, icon: Image, count: Int?, truncationMode: Text.TruncationMode) -> some View {
        HStack(spacing: 8) {
            icon.scaledIcon(size: 18)
                .instBadge(count, style: .hostSize18, isOverlayed: false, color: viewModel.contextColor)
                .accessibilityHidden(true)
            Text(title)
                .font(.regular16)
        }
        .lineLimit(1)
        .truncationMode(truncationMode)
        .foregroundStyle(viewModel.contextColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 12)
        .padding(.trailing, 16)
        .padding(.vertical, 8)
        .elevation(.pill, aboveBackground: .lightest)
    }

    // MARK: - Drawer

    private func tabsView(bottomInset: CGFloat, tabsContainerType: SpeedGraderPageTabsView.ContainerType) -> some View {
        SpeedGraderPageTabsView(
            containerType: tabsContainerType,
            bottomInset: bottomInset,
            selectedTab: $selectedTab,
            a11yFocusedTab: _a11yFocusedTab,
            drawerState: $drawerState,
            splitViewHeaderHeight: $headerHeight,
            viewModel: viewModel
        )
    }

    private func snapDrawer(to state: DrawerState) {
        withTransaction(DrawerState.transaction) {
            drawerState = state
        }
    }

    // MARK: - Rotation

    private func layout(for size: CGSize) -> Layout {
        // On iPads if the app is backgrounded then it changes the device orientation back and forth causing the UI to re-render and the submission to re-load.
        // To overcome this we force the last presented layout in case the app is in the background.
        guard UIApplication.shared.applicationState != .background else {
            return lastPresentedLayout
        }

        return size.width > size.height ? .landscape : .portrait
    }

    private func didChangeLayout(to layout: Layout) {
        lastPresentedLayout = layout
    }
}

// MARK: - Private helpers

private func interpolate(value: CGFloat, fromMin: CGFloat, fromMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
    let bounded = max(fromMin, min(value, fromMax))
    return (((toMax - toMin) / (fromMax - fromMin)) * (bounded - fromMin)) + toMin
}

#if DEBUG

#Preview {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .data)
}

#endif
