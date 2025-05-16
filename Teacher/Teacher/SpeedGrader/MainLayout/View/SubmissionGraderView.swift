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
            let minHeight = bottomInset + 58
            let maxHeight = bottomInset + geometry.size.height - 64
            // At 1/4 of a screen offset, scale to 90% and round corners to 20
            let delta = abs(geometry.frame(in: .global).minX / max(1, geometry.size.width))
            let scale = interpolate(value: delta, fromMin: 0, fromMax: 0.25, toMin: 1, toMax: 0.9)
            let cornerRadius = interpolate(value: delta, fromMin: 0, fromMax: 0.25, toMin: 0, toMax: 20)

            mainLayout(
                geometry: geometry,
                bottomInset: bottomInset,
                minHeight: minHeight,
                maxHeight: maxHeight
            )
            .background(Color.backgroundLightest)
            .cornerRadius(cornerRadius)
            .scaleEffect(scale)
            .edgesIgnoringSafeArea(.bottom)
        }
        .avoidKeyboardArea()
        .onSizeChange { newSize in
            // These conditions are to avoid reseting the landscape layout when the app is backgrounded or rotated to portrait.
            if layout(for: newSize) == .landscape, UIApplication.shared.applicationState != .background {
                landscapeSplitLayoutViewModel.updateScreenWidth(newSize.width)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func mainLayout(
        geometry: GeometryProxy,
        bottomInset: CGFloat,
        minHeight: CGFloat,
        maxHeight: CGFloat
    ) -> some View {
        switch layout(for: geometry.size) {
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
                    attemptToggle
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            SimilarityScoreView(viewModel.selectedAttempt, file: viewModel.file)
                            SubmissionViewer(
                                assignment: viewModel.assignment,
                                submission: viewModel.selectedAttempt,
                                fileID: viewModel.fileID,
                                studentAnnotationViewModel: viewModel.studentAnnotationViewModel,
                                handleRefresh: handleRefresh
                            )
                        }
                        // Disable submission content interaction in case attempt picker is above it
                        .accessibilityElement(children: showAttempts ? .ignore : .contain)
                        .accessibility(hidden: showAttempts)
                        attemptPicker
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
                attemptToggle
                    .accessibility(hidden: drawerState == .max)
                let isSubmissionContentHiddenFromA11y = (drawerState != .min || showAttempts)
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        SimilarityScoreView(viewModel.selectedAttempt, file: viewModel.file)
                        SubmissionViewer(
                            assignment: viewModel.assignment,
                            submission: viewModel.selectedAttempt,
                            fileID: viewModel.fileID,
                            studentAnnotationViewModel: viewModel.studentAnnotationViewModel,
                            handleRefresh: handleRefresh
                        )
                    }
                    .accessibilityElement(children: isSubmissionContentHiddenFromA11y ? .ignore : .contain)
                    .accessibility(hidden: isSubmissionContentHiddenFromA11y)
                    attemptPicker
                }
                Spacer().frame(height: drawerState == .min ? minHeight : (minHeight + maxHeight) / 2)
            }
            DrawerContainer(state: $drawerState, minHeight: minHeight, maxHeight: maxHeight) {
                tools(bottomInset: bottomInset, isDrawer: true)
            }
        }
        .onAppear { didChangeLayout(to: .portrait) }
    }

    @ViewBuilder
    private var attemptToggle: some View {
        if viewModel.hasSubmissions {
            Button {
                showAttempts.toggle()
            } label: {
                HStack {
                    Text("Attempt \(viewModel.selectedAttemptIndex)", bundle: .teacher)
                    Spacer()
                    Text(viewModel.selectedAttempt.submittedAt?.dateTimeString ?? "")
                        .frame(minHeight: 24)

                    if !viewModel.isSingleSubmission {
                        Image.arrowOpenDownLine
                            .resizable()
                            .frame(width: 14, height: 14)
                            .rotationEffect(.degrees(showAttempts ? 180 : 0))
                    }
                }
                .font(.regular14)
                .foregroundColor(.textDark)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
            }
            .disabled(viewModel.isSingleSubmission)
            InstUI.Divider()
        }
    }

    @ViewBuilder
    private var attemptPicker: some View {
        if showAttempts {
            VStack(spacing: 0) {
                let binding = Binding(
                    get: {
                        viewModel.selectedAttemptIndex
                    },
                    set: { newAttemptIndex in
                        withTransaction(.exclusive()) {
                            viewModel.didSelectNewAttempt(attemptIndex: newAttemptIndex)
                        }
                        showAttempts = false
                    }
                )
                Picker(selection: binding, label: Text(verbatim: "")) {
                    ForEach(viewModel.attempts, id: \.attempt) { attempt in
                        Text(attempt.submittedAt?.dateTimeString ?? "")
                            .tag(Optional(attempt.attempt))
                    }
                }
                .labelsHidden()
                .pickerStyle(WheelPickerStyle())
                InstUI.Divider()
            }
            .background(Color.backgroundLightest)
        }
    }

    // MARK: - Drawer

    enum GraderTab: Int, CaseIterable {
        case grades, comments, files

        func title(viewModel: SubmissionGraderViewModel) -> String {
            switch self {
            case .grades: return String(localized: "Grades", bundle: .teacher)
            case .comments: return String(localized: "Comments", bundle: .teacher)
            case .files: return viewModel.fileTabTitle
            }
        }
    }

    @ViewBuilder
    private func tools(bottomInset: CGFloat, isDrawer: Bool) -> some View {
        VStack(spacing: 0) {
            if isDrawer {
                let titles = GraderTab.allCases.map {
                    $0.title(viewModel: viewModel)
                }
                OldSegmentedPicker(
                    titles,
                    selectedIndex: Binding(
                        get: { selectedDrawerTabIndex },
                        set: { newValue in
                            selectedDrawerTabIndex = newValue ?? 0
                            if drawerState == .min {
                                snapDrawerTo(.mid)
                            }
                            let newTab = SubmissionGraderView.GraderTab(rawValue: newValue ?? 0)!
                            withAnimation(.default) {
                                tab = newTab
                            }
                            controller.view.endEditing(true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                focusedTab = tab
                            }
                        }
                    ),
                    selectionAlignment: .bottom,
                    content: { item, _ in
                        Text(item)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                )
                .identifier("SpeedGrader.toolPicker")
                InstUI.Divider()
            } else {
                InstUI.SegmentedPicker(selection: $tab.animation()) {
                    ForEach(GraderTab.allCases, id: \.self) { tab in
                        Text(tab.title(viewModel: viewModel))
                            .tag(tab)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: profileHeaderSize.height)
                .onChange(of: tab) {
                    controller.view.endEditing(true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        focusedTab = tab
                    }
                }
                .identifier("SpeedGrader.toolPicker")
                InstUI.Divider()
            }
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    let drawerFileID = Binding<String?>(
                        get: {
                            viewModel.fileID
                        },
                        set: {
                            viewModel.didSelectFile(fileID: $0)
                            snapDrawerTo(.min)
                        }
                    )

                    gradesTab(bottomInset: bottomInset, isDrawer: isDrawer, geometry: geometry)
                    commentsTab(bottomInset: bottomInset, isDrawer: isDrawer, fileID: drawerFileID, geometry: geometry)
                    filesTab(bottomInset: bottomInset, isDrawer: isDrawer, fileID: drawerFileID, geometry: geometry)
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .background(Color.backgroundLightest)
                .offset(x: -CGFloat(tab.rawValue) * geometry.size.width)
            }
            .clipped()
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
                viewModel.selectedAttemptIndex
            }, set: {
                viewModel.didSelectNewAttempt(attemptIndex: $0)
                snapDrawerTo(.min)
            }
        )
        let isCommentsOnScreen = isGraderTabOnScreen(.comments, isDrawer: isDrawer)
        VStack(spacing: 0) {
            SubmissionCommentListView(
                assignment: viewModel.assignment,
                submission: viewModel.submission,
                attempts: viewModel.attempts,
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
        .background(Color.backgroundLight)
        .accessibilityElement(children: isCommentsOnScreen ? .contain : .ignore)
        .accessibility(hidden: !isCommentsOnScreen)
    }

    @ViewBuilder
    private func filesTab(
        bottomInset: CGFloat,
        isDrawer: Bool,
        fileID: Binding<String?>,
        geometry: GeometryProxy
    ) -> some View {
        let isFilesOnScreen = isGraderTabOnScreen(.files, isDrawer: isDrawer)
        VStack(spacing: 0) {
            SubmissionFileList(submission: viewModel.selectedAttempt, fileID: fileID)
                .clipped()
            Spacer().frame(height: bottomInset)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .accessibilityElement(children: isFilesOnScreen ? .contain : .ignore)
        .accessibility(hidden: !isFilesOnScreen)
        .accessibilityFocused($focusedTab, equals: .files)
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
        if lastPresentedLayout != layout {
            // When the layout changes the keyboard disappears without any system notifications
            // on iPads so we simulate one to allow .avoidKeyboardArea() to work correctly.
            NotificationCenter.default.post(name: UIApplication.keyboardWillHideNotification, object: nil, userInfo: [:])
        }
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
