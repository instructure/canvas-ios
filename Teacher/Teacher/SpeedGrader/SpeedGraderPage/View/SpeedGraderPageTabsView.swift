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

import Core
import Foundation
import SwiftUI

struct SpeedGraderPageTabsView: View {

    enum ContainerType {
        case drawer
        case splitView
    }

    @Environment(\.viewController) private var controller
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let containerType: ContainerType
    private let bottomInset: CGFloat

    @Binding private var selectedTab: SpeedGraderPageTab
    @AccessibilityFocusState private var focusedTab: SpeedGraderPageTab?
    @Binding private var drawerState: DrawerState
    @Binding private var splitViewHeaderHeight: CGFloat

    @StateObject private var viewModel: SpeedGraderPageViewModel
    @StateObject private var rubricsViewModel: RubricsViewModel

    init(
        containerType: ContainerType,
        bottomInset: CGFloat,
        selectedTab: Binding<SpeedGraderPageTab>,
        focusedTab: AccessibilityFocusState<SpeedGraderPageTab?>,
        drawerState: Binding<DrawerState>,
        splitViewHeaderHeight: Binding<CGFloat>,
        viewModel: SpeedGraderPageViewModel
    ) {
        self.containerType = containerType
        self.bottomInset = bottomInset
        self._selectedTab = selectedTab
        self._focusedTab = focusedTab
        self._drawerState = drawerState
        self._splitViewHeaderHeight = splitViewHeaderHeight

        self._viewModel = StateObject(wrappedValue: viewModel)
        _rubricsViewModel = StateObject(
            wrappedValue: RubricsViewModel(
                assignment: viewModel.assignment,
                submission: viewModel.submission,
                interactor: RubricGradingInteractorLive(assignment: viewModel.assignment, submission: viewModel.submission)
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch containerType {
                case .drawer:
                    tabPicker
                        .padding(.bottom, 16)
                case .splitView:
                    tabPicker
                        .frame(height: splitViewHeaderHeight)
                }
            }
            .padding(.horizontal, 16)
            .onChange(of: selectedTab) {
                if drawerState.isClosed {
                    snapDrawer(to: .mid)
                }
                controller.view.endEditing(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedTab = selectedTab
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
                            snapDrawer(to: .min)
                        }
                    )

                    gradesTab(bottomInset: bottomInset, geometry: geometry)
                        // `.clipped` and `.contentShape` don't prevent touches outside of the drawer on iOS17
                        // and it would block interaction with the attempts picker and the submission content.
                        .allowsHitTesting(selectedTab == .grades)
                    commentsTab(bottomInset: bottomInset, fileID: drawerFileID, geometry: geometry)
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .background(Color.backgroundLightest)
                .offset(x: -CGFloat(selectedTab.rawValue) * geometry.size.width)
            }
            // Since we are offsetting the content, we need to clip it to avoid showing other tabs outside of the drawer.
            .clipped()
            // Clipping won't prevent user interaction so we need to limit it not to swallow touches outside of the drawer.
            .contentShape(Rectangle())
        }
    }

    private var tabPicker: some View {
        InstUI.SegmentedPicker(selection: $selectedTab) {
            ForEach(SpeedGraderPageTab.allCases, id: \.self) { tab in
                Text(tab.title)
                    .tag(tab)
            }
        }
    }

    private func snapDrawer(to state: DrawerState) {
        withTransaction(DrawerState.transaction) {
            drawerState = state
        }
    }

    private func isTabOnScreen(_ tab: SpeedGraderPageTab) -> Bool {
        let isTabSelected = (self.selectedTab == tab)

        switch containerType {
        case .drawer:
            return (drawerState.isOpen && isTabSelected)
        case .splitView:
            return isTabSelected
        }
    }

    // MARK: - Tab Contents

    @ViewBuilder
    private func gradesTab(
        bottomInset: CGFloat,
        geometry: GeometryProxy
    ) -> some View {
        let isGradesOnScreen = isTabOnScreen(.grades)
        VStack(spacing: 0) {
            SubmissionGrades(
                assignment: viewModel.assignment,
                containerHeight: geometry.size.height,
                submission: viewModel.submission,
                rubricsViewModel: rubricsViewModel,
                gradeStatusViewModel: viewModel.gradeStatusViewModel
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
        fileID: Binding<String?>,
        geometry: GeometryProxy
    ) -> some View {
        let drawerAttempt = Binding(
            get: {
                viewModel.selectedAttemptNumber
            }, set: {
                viewModel.didSelectAttempt(attemptNumber: $0)
                snapDrawer(to: .min)
            }
        )
        let isCommentsOnScreen = isTabOnScreen(.comments)
        VStack(spacing: 0) {
            SubmissionCommentListView(
                viewModel: viewModel.commentListViewModel,
                attempt: drawerAttempt,
                fileID: fileID,
                focusedTab: _focusedTab
            )
            .clipped()
            if drawerState.isClosed {
                Spacer().frame(height: bottomInset)
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .accessibilityElement(children: isCommentsOnScreen ? .contain : .ignore)
        .accessibility(hidden: !isCommentsOnScreen)
    }
}

#if DEBUG

#Preview {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .data)
}

#endif
