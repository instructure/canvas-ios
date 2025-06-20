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

struct SubmissionGraderView: View {
    private enum Layout {
        case portrait
        case landscape // only on iPads no matter the iPhone screen size
    }

    let userIndexInSubmissionList: Int

    @Environment(\.viewController) private var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedDrawerTabIndex = 0
    @State private var drawerState: DrawerState = .min
    @State private var showAttempts = false
    @State private var tab: GraderTab = .grades
    @State private var showRecorder: MediaCommentType?
    /** Used to work around an issue which caused the page to re-load after putting the app into background. See `layoutForWidth()` method for more. */
    @State private var lastPresentedLayout: Layout = .portrait
    /// Used to match landscape drawer's segmented control height with the header height.
    @State private var profileHeaderSize: CGSize = .zero
    @AccessibilityFocusState private var focusedTab: GraderTab?

    @StateObject private var commentLibrary = SubmissionCommentLibraryViewModel()
    @StateObject private var rubricsViewModel: RubricsViewModel
    @StateObject private var viewModel: SubmissionGraderViewModel
    @ObservedObject private var landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel

    private var handleRefresh: (() -> Void)?
    /// We can't measure the view's size because when keyboard appears it shrinks it
    /// and that would cause the layout to switch from portrait to landscape. We use the
    /// navigation controller's view size instead to decide which layout to use.
    private var containerSize: CGSize {
        controller.value.navigationController?.view.frame.size ?? .zero
    }

    private var openCloseButtonAccessibilityLabel: String {
        drawerState != .min ?
        String(localized: "Close", bundle: .teacher) :
        String(localized: "Open", bundle: .teacher)
    }

    private var expandCollapseButtonAccessibilityLabel: String {
        drawerState != .max ?
        String(localized: "Expand", bundle: .teacher) :
        String(localized: "Collapse", bundle: .teacher)
    }

    init(
        env: AppEnvironment,
        userIndexInSubmissionList: Int,
        viewModel: SubmissionGraderViewModel,
        landscapeSplitLayoutViewModel: SpeedGraderLandscapeSplitLayoutViewModel,
        handleRefresh: (() -> Void)?
    ) {
        self.userIndexInSubmissionList = userIndexInSubmissionList
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.landscapeSplitLayoutViewModel = landscapeSplitLayoutViewModel
        self.handleRefresh = handleRefresh
        _rubricsViewModel = StateObject(wrappedValue:
                                            RubricsViewModel(
                                                assignment: viewModel.assignment,
                                                submission: viewModel.submission,
                                                interactor: RubricGradingInteractorLive(assignment: viewModel.assignment, submission: viewModel.submission)
                                            )
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let bottomInset = geometry.safeAreaInsets.bottom
            let minHeight = bottomInset + 86
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

    private func landscapeLayout(
        bottomInset: CGFloat
    ) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                SubmissionHeaderView(
                    assignment: viewModel.assignment,
                    submission: viewModel.submission,
                    isLandscapeLayout: true,
                    landscapeSplitLayoutViewModel: landscapeSplitLayoutViewModel
                )
                .accessibility(sortPriority: 2)
                .onSizeChange(update: $profileHeaderSize)
                InstUI.Divider()

                VStack(alignment: .leading, spacing: 0) {

                    if viewModel.hasSubmissions {
                        attemptAndFilePickers
                        InstUI.Divider()
                    }

                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            SimilarityScoreView(viewModel.selectedAttempt, file: viewModel.selectedFile)
                            SubmissionViewer(
                                assignment: viewModel.assignment,
                                submission: viewModel.selectedAttempt,
                                fileID: viewModel.selectedFile?.id,
                                studentAnnotationViewModel: viewModel.studentAnnotationViewModel,
                                handleRefresh: handleRefresh
                            )
                        }
                        // Disable submission content interaction in case attempt picker is above it
                        .accessibilityElement(children: showAttempts ? .ignore : .contain)
                        .accessibility(hidden: showAttempts)
                    }
                    Spacer().frame(height: bottomInset)
                }
                .zIndex(1)
                .accessibility(sortPriority: 1)
            }
            .frame(width: landscapeSplitLayoutViewModel.leftColumnWidth)
            InstUI.Divider()
            tools(bottomInset: bottomInset, isDrawer: false)
                .frame(width: landscapeSplitLayoutViewModel.rightColumnWidth)
                .hidden(landscapeSplitLayoutViewModel.isRightColumnHidden)
        }
        .onAppear { didChangeLayout(to: .landscape) }
        .onChange(of: landscapeSplitLayoutViewModel.isRightColumnHidden) { _, isHidden in
            // Auto focus voiceover on the selected tab when the right column is shown
            if isHidden { return }
            focusedTab = tab
        }
    }

    private func portraitLayout(
        minHeight: CGFloat,
        maxHeight: CGFloat,
        bottomInset: CGFloat
    ) -> some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                SubmissionHeaderView(
                    assignment: viewModel.assignment,
                    submission: viewModel.submission,
                    isLandscapeLayout: false,
                    landscapeSplitLayoutViewModel: landscapeSplitLayoutViewModel
                )
                InstUI.Divider()

                if viewModel.hasSubmissions {
                    attemptAndFilePickers
                        .accessibility(hidden: drawerState == .max)
                    InstUI.Divider()
                }

                let isSubmissionContentHiddenFromA11y = (drawerState != .min || showAttempts)

                VStack(spacing: 0) {
                    SimilarityScoreView(viewModel.selectedAttempt, file: viewModel.selectedFile)
                    SubmissionViewer(
                        assignment: viewModel.assignment,
                        submission: viewModel.selectedAttempt,
                        fileID: viewModel.selectedFile?.id,
                        studentAnnotationViewModel: viewModel.studentAnnotationViewModel,
                        handleRefresh: handleRefresh
                    )
                }
                .accessibilityElement(children: isSubmissionContentHiddenFromA11y ? .ignore : .contain)
                .accessibility(hidden: isSubmissionContentHiddenFromA11y)

                Spacer()
                    .frame(height: drawerState == .min ? minHeight : (minHeight + maxHeight) / 2)
            }

            DrawerContainer(state: $drawerState, minHeight: minHeight, maxHeight: maxHeight) {
                tools(bottomInset: bottomInset, isDrawer: true)
            } leadingContent: {
                Button {
                    drawerState != .mid ? snapDrawerTo(.mid) : snapDrawerTo(.max)
                } label: {
                    drawerState != .max ? Image.fullScreenLine : Image.exitFullScreenLine
                }
                .accessibilityLabel(expandCollapseButtonAccessibilityLabel)
                .accessibilityShowsLargeContentViewer {
                    drawerState != .max ? Image.fullScreenLine : Image.exitFullScreenLine
                    Text(expandCollapseButtonAccessibilityLabel)
                }
            } trailingContent: {
                Button {
                    drawerState != .min ? snapDrawerTo(.min) : snapDrawerTo(.max)
                } label: {
                    drawerState != .min ? Image.arrowOpenDownLine : Image.arrowOpenUpLine
                }
                .accessibilityLabel(openCloseButtonAccessibilityLabel)
                .accessibilityShowsLargeContentViewer {
                    drawerState != .min ? Image.arrowOpenDownLine : Image.arrowOpenUpLine
                    Text(openCloseButtonAccessibilityLabel)
                }
            }
            .accessibilityAddTraits(drawerState == .max ? .isModal : [])
        }
        .onAppear { didChangeLayout(to: .portrait) }
    }

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
        snapDrawerTo(.min)
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

    enum GraderTab: Int, CaseIterable {
        case grades
        case comments

        func title(viewModel: SubmissionGraderViewModel) -> String {
            switch self {
            case .grades: return String(localized: "Grades", bundle: .teacher)
            case .comments: return String(localized: "Comments", bundle: .teacher)
            }
        }
    }

    @ViewBuilder
    private func tools(bottomInset: CGFloat, isDrawer: Bool) -> some View {
        VStack(spacing: 0) {
            InstUI.SegmentedPicker(selection: $tab) {
                ForEach(GraderTab.allCases, id: \.self) { tab in
                    Text(tab.title(viewModel: viewModel))
                        .tag(tab)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .onChange(of: tab) {
                controller.view.endEditing(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedTab = tab
                }
            }
            .identifier("SpeedGrader.toolPicker")
            InstUI.Divider()

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    let drawerFileID = Binding<String?>(
                        get: {
                            viewModel.selectedFile?.id
                        },
                        set: {
                            viewModel.didSelectFile(fileId: $0)
                            snapDrawerTo(.min)
                        }
                    )

                    gradesTab(bottomInset: bottomInset, isDrawer: isDrawer, geometry: geometry)
                        // `.clipped` and `.contentShape` don't prevent touches outside of the drawer on iOS17
                        // and it would block interaction with the attempts picker and the submission content.
                        .allowsHitTesting(tab == .grades)
                    commentsTab(bottomInset: bottomInset, isDrawer: isDrawer, fileID: drawerFileID, geometry: geometry)
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .background(Color.backgroundLightest)
                .offset(x: -CGFloat(tab.rawValue) * geometry.size.width)
            }
            // Since we are offsetting the content, we need to clip it to avoid showing other tabs outside of the drawer.
            .clipped()
            // Clipping won't prevent user interaction so we need to limit it not to swallow touches outside of the drawer.
            .contentShape(Rectangle())
        }
    }

    private func snapDrawerTo(_ state: DrawerState) {
        withTransaction(DrawerState.transaction) {
            drawerState = state
        }
    }

    private func isGraderTabOnScreen(_ tab: GraderTab, isDrawer: Bool) -> Bool {
        let isTabSelected = (self.tab == tab)

        if isDrawer {
            return (drawerState != .min && isTabSelected)
        } else {
            return isTabSelected
        }
    }

    // MARK: - Tab Contents

    @ViewBuilder
    private func gradesTab(
        bottomInset: CGFloat,
        isDrawer: Bool,
        geometry: GeometryProxy
    ) -> some View {
        let isGradesOnScreen = isGraderTabOnScreen(.grades, isDrawer: isDrawer)
        VStack(spacing: 0) {
            SubmissionGrades(
                assignment: viewModel.assignment,
                containerHeight: geometry.size.height,
                submission: viewModel.submission,
                rubricsViewModel: rubricsViewModel
            )
            .clipped()
            Spacer().frame(height: bottomInset)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .accessibilityElement(children: isGradesOnScreen ? .contain : .ignore)
        .accessibility(hidden: !isGradesOnScreen)
        .accessibilityFocused($focusedTab, equals: .grades)
    }

    @ViewBuilder
    private func commentsTab(
        bottomInset: CGFloat,
        isDrawer: Bool,
        fileID: Binding<String?>,
        geometry: GeometryProxy
    ) -> some View {
        let drawerAttempt = Binding(
            get: {
                viewModel.selectedAttemptNumber
            }, set: {
                viewModel.didSelectAttempt(attemptNumber: $0)
                snapDrawerTo(.min)
            }
        )
        let isCommentsOnScreen = isGraderTabOnScreen(.comments, isDrawer: isDrawer)
        VStack(spacing: 0) {
            SubmissionCommentListView(
                viewModel: viewModel.commentListViewModel,
                attempt: drawerAttempt,
                fileID: fileID,
                showRecorder: $showRecorder,
                enteredComment: $viewModel.enteredComment,
                commentLibrary: commentLibrary,
                focusedTab: _focusedTab
            )
            .clipped()
            if showRecorder != .video || drawerState == .min {
                Spacer().frame(height: bottomInset)
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .accessibilityElement(children: isCommentsOnScreen ? .contain : .ignore)
        .accessibility(hidden: !isCommentsOnScreen)
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

private func interpolate(value: CGFloat, fromMin: CGFloat, fromMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
    let bounded = max(fromMin, min(value, fromMax))
    return (((toMax - toMin) / (fromMax - fromMin)) * (bounded - fromMin)) + toMin
}

#if DEBUG

#Preview {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .data)
}

#endif
