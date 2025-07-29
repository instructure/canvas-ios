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
    @AccessibilityFocusState private var a11yFocusedTab: SpeedGraderPageTab?
    @Binding private var drawerState: DrawerState
    @Binding private var splitViewHeaderHeight: CGFloat

    @StateObject private var viewModel: SpeedGraderPageViewModel

    init(
        containerType: ContainerType,
        bottomInset: CGFloat,
        selectedTab: Binding<SpeedGraderPageTab>,
        a11yFocusedTab: AccessibilityFocusState<SpeedGraderPageTab?>,
        drawerState: Binding<DrawerState>,
        splitViewHeaderHeight: Binding<CGFloat>,
        viewModel: SpeedGraderPageViewModel
    ) {
        self.containerType = containerType
        self.bottomInset = bottomInset
        self._selectedTab = selectedTab
        self._a11yFocusedTab = a11yFocusedTab
        self._drawerState = drawerState
        self._splitViewHeaderHeight = splitViewHeaderHeight

        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch containerType {
                case .drawer:
                    tabPicker(shouldOpenDrawerIfNeeded: true)
                        .padding(.bottom, 16)
                case .splitView:
                    tabPicker(shouldOpenDrawerIfNeeded: false)
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
                    a11yFocusedTab = selectedTab
                }
            }
            .identifier("SpeedGrader.toolPicker")

            InstUI.Divider()

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    gradesTab(geometry: geometry)
                        // `.clipped` and `.contentShape` don't prevent touches outside of the drawer on iOS17
                        // and it would block interaction with the attempts picker and the submission content.
                        .allowsHitTesting(selectedTab == .grades)
                    detailsTab(geometry: geometry)
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

    @ViewBuilder
    private func tabPicker(shouldOpenDrawerIfNeeded: Bool) -> some View {
        let content = {
            ForEach(SpeedGraderPageTab.allCases, id: \.self) { tab in
                Text(tabTitle(tab))
                    .tag(tab)
            }
        }
        if shouldOpenDrawerIfNeeded {
            InstUI.SegmentedPicker(
                selection: $selectedTab,
                segmentCount: SpeedGraderPageTab.allCases.count,
                onTapSelectedTab: {
                    if drawerState.isClosed {
                        snapDrawer(to: .mid)
                    }
                },
                content: content
            )
        } else {
            InstUI.SegmentedPicker(
                selection: $selectedTab,
                content: content
            )
        }
    }

    // MARK: - Tab Contents

    @ViewBuilder
    private func gradesTab(geometry: GeometryProxy) -> some View {
        let attempt = Binding { viewModel.selectedAttemptNumber } set: {
            viewModel.didSelectAttempt(attemptNumber: $0)
            snapDrawer(to: .min)
        }

        let fileID = Binding { viewModel.selectedFile?.id } set: {
            viewModel.didSelectFile(fileId: $0)
            snapDrawer(to: .min)
        }

        VStack(spacing: 0) {
            SpeedGraderSubmissionGradesView(
                assignment: viewModel.assignment,
                containerHeight: geometry.size.height,
                attempt: attempt,
                fileID: fileID,
                gradeViewModel: viewModel.gradeViewModel,
                gradeStatusViewModel: viewModel.gradeStatusViewModel,
                commentListViewModel: viewModel.commentListViewModel,
                rubricsViewModel: viewModel.rubricsViewModel
            )
            .clipped()
            Spacer().frame(height: bottomInset)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .accessibilityElement(children: .contain)
        .accessibilityHidden(!isTabOnScreen(.grades))
        .accessibilityFocused($a11yFocusedTab, equals: .grades)
    }

    @ViewBuilder
    private func detailsTab(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            detailsTabContent
                .clipped()
            Spacer().frame(height: bottomInset)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .accessibilityElement(children: .contain)
        .accessibilityHidden(!isTabOnScreen(.details))
        .accessibilityFocused($a11yFocusedTab, equals: .details)
    }

    private var detailsTabContent: some View {
        InstUI.BaseScreen(
            state: viewModel.isDetailsTabEmpty ? .empty : .data,
            config: .init(
                refreshable: false,
                emptyPandaConfig: .empty(
                    title: String(localized: "We don’t have further details for this Student and Assignment", bundle: .teacher),
                    subtitle: nil
                )
            )
        ) { _ in
            VStack(spacing: 0) {
                InstUI.TopDivider()

                if viewModel.submissionWordCountViewModel.hasContent {
                    InstUI.LabelValueCell(
                        label: Text("Word Count", bundle: .teacher),
                        value: viewModel.submissionWordCountViewModel.wordCount
                    )
                }

                if viewModel.studentNotesViewModel.hasContent {
                    StudentNotesView(viewModel: viewModel.studentNotesViewModel)
                }
            }
        }
    }

    // MARK: - Private helpers

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

    private func tabTitle(_ tab: SpeedGraderPageTab) -> String {
        switch (tab, viewModel.assignment.rubric?.isEmpty) {
        case (.details, _): String(localized: "Details", bundle: .teacher)
        case (.grades, nil), (.grades, .some(true)): String(localized: "Grade", bundle: .teacher)
        case (.grades, .some(false)): String(localized: "Grade & Rubric", bundle: .teacher)
        }
    }
}

#if DEBUG

#Preview {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .data)
}

#endif
