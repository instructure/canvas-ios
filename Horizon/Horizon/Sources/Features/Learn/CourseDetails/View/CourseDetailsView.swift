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
    @Environment(\.dismiss) private var dismiss
    @State private var isShowHeader: Bool = true
    private let threshold: CGFloat = -100
    private var tabs: [Tabs] {
        let showingOverview = !viewModel.course.overviewDescription.isEmpty
        return (showingOverview ? [.overview] : []) + [.myProgress, .scores, .notebook]
    }

    // MARK: - Dependencies

    private let notebookView: NotebookView
    private let isBackButtonVisible: Bool

    // MARK: - Init

    init(
        viewModel: CourseDetailsViewModel,
        isBackButtonVisible: Bool = true
    ) {
        self.viewModel = viewModel
        self.notebookView = NotebookAssembly.makeView(courseID: viewModel.courseID)
        self.isBackButtonVisible = isBackButtonVisible
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if isShowHeader {
                headerView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            tabSelectorView
            ScrollView {
                topView
                learningContentView()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .padding(.top, .huiSpaces.space12)
        .hidden(viewModel.isLoaderVisible)
        .background(Color.huiColors.surface.pagePrimary)
        .onAppear { viewModel.showTabBar() }
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .toolbar(.hidden)
        .animation(.linear, value: isShowHeader)
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
                    dismiss()
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
            Text(viewModel.course.name)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.primitives.black174)

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
            let selectedTab = tabs[safe: viewModel.selectedTabIndex] ?? .myProgress
            switch selectedTab {
            case .myProgress:
                modulesView(modules: viewModel.course.modules)
                    .id(viewModel.selectedTabIndex)
            case .overview:
                overview(htmlString: viewModel.course.overviewDescription)
                    .id(viewModel.selectedTabIndex)
            case .scores:
                ScoresAssembly.makeView(viewModel: viewModel.scoresViewModel)
            case .notebook:
                notebookView
            }
        }
        .padding(.huiSpaces.space24)
        .animation(.smooth, value: viewModel.selectedTabIndex)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                isShowHeader = frame.minY > threshold
            }
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

extension CourseDetailsView {
    enum Tabs: Int, CaseIterable, Identifiable {
        case overview
        case myProgress
        case scores
        case notebook
//        case quickLinks

        var localizedString: String {
            switch self {
            case .myProgress:
                return String(localized: "My Progress", bundle: .horizon)
            case .overview:
                return String(localized: "Overview", bundle: .horizon)
            case .scores:
                return String(localized: "Scores", bundle: .horizon)
            case .notebook:
                return String(localized: "Notebook", bundle: .horizon)
//            case .quickLinks:
//                return String(localized: "Quick Links", bundle: .horizon)
            }
        }

        var id: Self {
            self
        }
    }
}
