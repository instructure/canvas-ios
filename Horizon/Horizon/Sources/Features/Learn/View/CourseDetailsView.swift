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
    @Bindable private var viewModel: CourseDetailsViewModel
    @Environment(\.viewController) private var viewController
    @State var selectedTabIndex: Int = 0

    init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            headerView
            learningContentView()
        }
        .padding(.top, .huiSpaces.primitives.small)
        .background(Color.huiColors.surface.pagePrimary)
        .onAppear { viewModel.showTabBar() }
        .overlay {
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.primitives.mediumSmall) {
            Text(viewModel.course.name)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.primitives.black174)

            HorizonUI.ProgressBar(
                progress: viewModel.course.progress,
                size: .medium,
                textColor: .huiColors.primitives.white10
            )
        }
        .padding([.horizontal, .bottom], .huiSpaces.primitives.medium)
    }

    private func learningContentView() -> some View {
        VStack(spacing: .huiSpaces.primitives.medium) {
            tabSelectorView
            tabDetailsView()
        }
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var tabSelectorView: some View {
        HorizonUI.Tabs(
            tabs: Tabs.titles,
            selectTabIndex: Binding(
                get: { selectedTabIndex },
                set: { selectedTabIndex = $0 ?? 0 }
            )
        )
        .background(Color.huiColors.surface.pagePrimary)
    }

    private func tabDetailsView() -> some View {
        TabView(selection: $selectedTabIndex) {
            ForEach(Array(Tabs.allCases.enumerated()), id: \.offset) { index, tab in
                ScrollView(.vertical, showsIndicators: false) {
                    switch tab {
                    case .myProgress:
                        modulesView(modules: viewModel.course.modules).id(index)
                    case .overview:
                        overview(htmlString: viewModel.course.overviewDescription).id(index)
                    case .grades:
                        Text(verbatim: "Grades")
                            .id(index)
                    case .notebook:
                        Text(verbatim: "Notebook")
                            .id(index)
                    case .quickLinks:
                        Text(verbatim: "Quick Links")
                            .id(index)
                    }
                }
                .tag(index)
            }
        }
        .padding(.horizontal, .huiSpaces.primitives.medium)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.smooth, value: selectedTabIndex)
    }

    private func modulesView(modules: [HModule]) -> some View {
        VStack(spacing: .huiSpaces.primitives.xSmall) {
            ForEach(modules) { module in
                ExpandingModuleView(module: module) { url in
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
            WebView(html: htmlString)
                .clipShape(
                    .rect(
                        topLeadingRadius: 32,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 32
                    )
                )
                .containerRelativeFrame(.vertical)
        }
    }
}

extension CourseDetailsView {
    enum Tabs: CaseIterable, Identifiable {
        case myProgress
        case overview
        case grades
        case notebook
        case quickLinks

        var localizedString: String {
            switch self {
            case .myProgress:
                return String(localized: "My Progress", bundle: .horizon)
            case .overview:
                return String(localized: "Overview", bundle: .horizon)
            case .grades:
                return String(localized: "Grades", bundle: .horizon)
            case .notebook:
                return String(localized: "Notebook", bundle: .horizon)
            case .quickLinks:
                return String(localized: "Quick Links", bundle: .horizon)
            }
        }

        var id: Self {
            self
        }

        static var titles: [String] {
            Tabs.allCases.map(\.localizedString)
        }
    }
}
