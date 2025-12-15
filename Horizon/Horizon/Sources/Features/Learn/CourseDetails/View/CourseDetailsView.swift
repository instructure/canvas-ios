//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import HorizonUI
import SwiftUI

struct CourseDetailsView: View {
    @State private var viewModel: CourseDetailsViewModel
    @State private var isCourseDropdownVisible: Bool = false
    @State private var courseNameHeight: CGFloat = .zero
    @Environment(\.viewController) private var viewController

    private var tabs: [CourseDetailsTabs] {
        let showingOverview = !viewModel.overviewDescription.isEmpty
        var tabs: [CourseDetailsTabs] = (showingOverview ? [.overview] : []) + [.myProgress, .scores, .notebook]
        if viewModel.courseTools.isNotEmpty {
            tabs.append(.tools)
        }
        return tabs
    }
    // MARK: - Dependencies

    private let isBackButtonVisible: Bool
    private let shouldHideTabBar: Bool
    private let onShowNavigationBarAndTabBar: (Bool) -> Void
    private let onSwitchToLearnTab: (ProgramSwitcherModel?, WeakViewController) -> Void

    // MARK: - Init

    init(
        viewModel: CourseDetailsViewModel,
        isBackButtonVisible: Bool = true,
        shouldHideTabBar: Bool = false,
        onShowNavigationBarAndTabBar: @escaping (Bool) -> Void,
        onSwitchToLearnTab: @escaping (ProgramSwitcherModel?, WeakViewController) -> Void
    ) {
        self.viewModel = viewModel
        self.shouldHideTabBar = shouldHideTabBar
        self.isBackButtonVisible = isBackButtonVisible
        self.onShowNavigationBarAndTabBar = onShowNavigationBarAndTabBar
        self.onSwitchToLearnTab = onSwitchToLearnTab
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if viewModel.isShowHeader {
                VStack(spacing: .zero) {
                    VStack(spacing: .zero) {
                        if let programName = viewModel.selectedProgram?.name {
                            ProgramNameView(name: programName)
                                .padding(.horizontal, .huiSpaces.space24)
                                .padding(.bottom, .huiSpaces.space16)
                                .onTapGesture {
                                    onSwitchToLearnTab(.init(id: viewModel.selectedProgram?.id), viewController)
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(viewModel.selectedProgram?.accessibilityDescription)
                        }
                        ExpandTitleView(
                            title: viewModel.selectedCourse?.name ?? "",
                            isExpanded: isCourseDropdownVisible
                        )
                        .padding(.horizontal, .huiSpaces.space24)
                        .padding(.bottom, .huiSpaces.space16)
                        .onTapGesture { isCourseDropdownVisible.toggle() }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(viewModel.course.accessibilityDescription)
                    }
                    .readingFrame { frame in courseNameHeight = frame.height }
                    headerView
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture { isCourseDropdownVisible = false }
            }
            learningContentView()
        }
        .padding(.top, .huiSpaces.space12)
        .hidden(viewModel.isLoaderVisible)
        .background {
            Color.huiColors.surface.pagePrimary
                .ignoresSafeArea()
                .onTapGesture { isCourseDropdownVisible = false }
        }
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .onWillDisappear {
            isCourseDropdownVisible = false
            onShowNavigationBarAndTabBar(true)
        }
        .onWillAppear { onShowNavigationBarAndTabBar(false) }
        .overlay {
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
        .overlay(alignment: .top) {
            if isCourseDropdownVisible {
                ProgramSwitcherView(
                    isExpanded: $isCourseDropdownVisible,
                    isProgramPage: false,
                    programs: viewModel.programs,
                    selectedProgram: viewModel.selectedProgram,
                    selectedCourse: viewModel.selectedCourse,
                    onSelectProgram: { program in
                        onSwitchToLearnTab(program, viewController)
                    },
                    onSelectCourse: viewModel.onSelectCourse
                )
                .padding(.top, courseNameHeight + (isBackButtonVisible ? 40 : 0))
                .padding(.horizontal, .huiSpaces.space24)
            }
        }
        .animation(.linear, value: [viewModel.isShowHeader, isCourseDropdownVisible])
    }

    @ViewBuilder
    private var navigationBar: some View {
        if isBackButtonVisible {
            HStack {
                HorizonBackButton { _ in
                    viewModel.didTapBackButton(viewController: viewController)
                }
                Spacer()
            }
            .padding(.horizontal, .huiSpaces.space24)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            HorizonUI.ProgressBar(
                progress: viewModel.course.progress / 100,
                size: .medium,
                numberPosition: .outside
            )
            .id(viewModel.course.progress)
        }
        .padding([.horizontal, .bottom], .huiSpaces.space24)
        .accessibilityHidden(true)
    }

    private func learningContentView() -> some View {
        VStack(spacing: .huiSpaces.space16) {
            tabSelectorView
            tabDetailsView()
        }
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var tabSelectorView: some View {
        HorizonUI.Tabs(
            tabs: tabs.map(\.localizedString),
            selectTabIndex: Binding(
                get: { viewModel.selectedTabIndex },
                set: { viewModel.selectedTabIndex = $0 ?? 0 }
            )
        )
        .background(Color.huiColors.surface.pagePrimary)
    }

    private func tabDetailsView() -> some View {
        TabView(selection: $viewModel.selectedTabIndex) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                ScrollView(.vertical, showsIndicators: false) {
                    topView
                    ContentView(selectedTab: tab, viewModel: viewModel)
                }
                .tag(index)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.smooth, value: viewModel.selectedTabIndex)
    }

    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                // Need to make sure the tabBar is visible before starting the animation, because we hide it when going through the module item sequence.
                if viewController.isTabBarVisible || shouldHideTabBar {
                    viewModel.showHeaderPublisher.send(frame.minY > -100)
                }
            }
    }
}

private struct ContentView: View {
    @Environment(\.viewController) private var viewController
    let selectedTab: CourseDetailsTabs
    let viewModel: CourseDetailsViewModel

    var body: some View {
        switch selectedTab {
        case .myProgress:
            modulesView(modules: viewModel.course.modules)
                .padding([.bottom, .horizontal], .huiSpaces.space24)
                .id(viewModel.course.id)
        case .overview:
            overview(htmlString: viewModel.overviewDescription)
        case .scores:
            if let scoresViewModel = viewModel.scoresViewModel {
                ScoresView(viewModel: scoresViewModel)
                    .padding(.horizontal, .huiSpaces.space24)
            }
        case .notebook:
            NotebookAssembly.makeView(courseID: viewModel.course.id)
                .padding(.bottom, .huiSpaces.space24)
                .id(viewModel.course.id)
        case .tools:
            ListCourseToolsView(items: viewModel.courseTools) { url in
                viewModel.openSafari(url: url, viewController: viewController)
            }
            .padding(.bottom, .huiSpaces.space24)
            .id(viewModel.course.id)
        }
    }

    private func modulesView(modules: [HModule]) -> some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(modules) { module in
                ExpandingModuleView(module: module, isExpanded: true) { item in
                    viewModel.moduleItemDidTap(item: item, from: viewController)
                }
                .frame(minHeight: 44)
                .background(Color.huiColors.surface.cardPrimary)
                .huiCornerRadius(level: .level2)
            }
        }
    }

    @ViewBuilder
    private func overview(htmlString: String?) -> some View {
        if let htmlString {
            WebView(html: htmlString, isScrollEnabled: false)
                .frameToFit()
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
    }
}

extension WeakViewController {
   fileprivate var isTabBarVisible: Bool {
        !((value.tabBarController?.tabBar.isHidden) ?? true)
    }
}
