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
    @Environment(\.viewController) private var viewController

    private var tabs: [CourseDetailsTabs] {
        let showingOverview = !viewModel.overviewDescription.isEmpty
        return (showingOverview ? [.overview] : []) + [.myProgress, .scores, .notebook]
    }
    // MARK: - Dependencies

    private let isBackButtonVisible: Bool
    private let shouldHideTabBar: Bool
    private let onShowNavigationBarAndTabBar: (Bool) -> Void
    // MARK: - Init

    init(
        viewModel: CourseDetailsViewModel,
        isBackButtonVisible: Bool = true,
        shouldHideTabBar: Bool = false,
        onShowNavigationBarAndTabBar: @escaping (Bool) -> Void
    ) {
        self.viewModel = viewModel
        self.shouldHideTabBar = shouldHideTabBar
        self.isBackButtonVisible = isBackButtonVisible
        self.onShowNavigationBarAndTabBar = onShowNavigationBarAndTabBar
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if viewModel.isShowHeader {
                Group {
                    // Hide courses DropdownMenu
                    DropdownMenu(
                        items: viewModel.courses,
                        selectedItem: viewModel.selectedCoure,
                        onSelect: viewModel.onSelectCourse
                    )
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.bottom, .huiSpaces.space16)

                    headerView
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            learningContentView()
        }
        .padding(.top, .huiSpaces.space12)
        .hidden(viewModel.isLoaderVisible)
        .animation(.linear, value: viewModel.isShowHeader)
        .background(Color.huiColors.surface.pagePrimary)
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .onWillDisappear { onShowNavigationBarAndTabBar(true) }
        .onWillAppear { onShowNavigationBarAndTabBar(false) }
        .overlay {
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }

    @ViewBuilder
    private var navigationBar: some View {
        if isBackButtonVisible {
            HStack {
                Button {
                    viewModel.didTapBackButton(viewController: viewController)
                } label: {
                    Image.huiIcons.arrowBack
                        .foregroundStyle(Color.huiColors.icon.default)
                        .frame(width: 44, height: 44, alignment: .leading)

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
        }
        .padding([.horizontal, .bottom], .huiSpaces.space24)
    }

    private func learningContentView() -> some View {
        VStack(spacing: .huiSpaces.space24) {
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
                    CotentView(selectedTab: tab, viewModel: viewModel)
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

private struct CotentView: View {
    @Environment(\.viewController) private var viewController
    let selectedTab: CourseDetailsTabs
    let viewModel: CourseDetailsViewModel

    var body: some View {
        switch selectedTab {
        case .myProgress:
            modulesView(modules: viewModel.course.modules)
                .padding(.bottom, .huiSpaces.space24)
                .id(viewModel.course.id)
        case .overview:
            overview(htmlString: viewModel.overviewDescription)
                .padding(.bottom, .huiSpaces.space24)
        case .scores:
            ScoresAssembly.makeView(courseID: viewModel.course.id, enrollmentID: viewModel.course.enrollmentID)
                .padding(.horizontal, .huiSpaces.space24)
        case .notebook:
            NotebookAssembly.makeView(courseID: viewModel.course.id)
                .padding(.bottom, .huiSpaces.space24)
                .id(viewModel.course.id)
        }
    }

    private func modulesView(modules: [HModule]) -> some View {
        VStack(spacing: .huiSpaces.space8) {
            ForEach(modules) { module in
                ExpandingModuleView(module: module, isExpanded: true) { url in
                    viewModel.moduleItemDidTap(url: url, from: viewController)
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
