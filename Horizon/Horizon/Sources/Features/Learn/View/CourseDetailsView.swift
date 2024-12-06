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

struct CourseDetailsViewView: View {
    @ObservedObject private var viewModel: CourseDetailsViewModel
    @Environment(\.viewController) private var viewController
    @State private var selectedTabIndex: Int?
    @State private var selectedTabDetailsIndex = 0

    init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
        self.selectedTabIndex = 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Size24BoldTextDarkestTitle(title: viewModel.course.name)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            Size12RegularTextDarkTitle(title: viewModel.course.institutionName)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            Size12RegularTextDarkTitle(title: viewModel.course.targetCompletion)
                .padding(.horizontal, 16)
            CertificateProgressBar(
                maxWidth: 325,
                progress: viewModel.course.progress,
                progressString: viewModel.course.progressString
            )
            .padding([.horizontal, .bottom], 16)
            learningContentView(course: viewModel.course)
        }
        .containerRelativeFrame(.vertical)
        .safeAreaPadding(.bottom, 16)
        .padding(.top, 16)
        .background(Color.backgroundLight)
        .onFirstAppear {
            selectedTabIndex = 0
        }
    }

    @ViewBuilder
    private func learningContentView(course: HCourse) -> some View {
        VStack {
            tabSelectorView
            tabDetailsView(course: course)
        }
        .background(Color.backgroundLight)
    }

    private var tabSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(Tabs.allCases.enumerated()), id: \.offset) { index, tab in
                    Button {
                        selectedTabIndex = index
                        selectedTabDetailsIndex = index
                    } label: {
                        VStack {
                            Size14RegularTextDarkestTitle(title: tab.localizedString)
                            if index == selectedTabIndex {
                                Rectangle()
                                    .foregroundColor(Color.red)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxHeight: 44)
                    }
                    .id(index)
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
        }
        .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id: $selectedTabIndex, anchor: .center)
        .animation(.smooth, value: selectedTabIndex)
        .padding(.horizontal, 16)

        // Re-enable if ScrollView drag gesture is needed.
        /*
         .onChange(of: selectedCourseIndex) {
             if let selectedCourseIndex, selectedCourseIndex != selectedCourseDetailsIndex {
                 selectedCourseDetailsIndex = selectedCourseIndex
             }
         }
         */
    }

    @ViewBuilder
    private func tabDetailsView(course: HCourse) -> some View {
        TabView(selection: $selectedTabDetailsIndex) {
            ForEach(Array(Tabs.allCases.enumerated()), id: \.offset) { index, tab in
                ScrollView(.vertical, showsIndicators: false) {
                    switch tab {
                    case .myProgress:
                        modulesView(modules: course.modules).id(index)
                    case .overview:
                        overview(htmlString: course.overviewDescription).id(index)
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
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: selectedTabDetailsIndex) {
            selectedTabIndex = selectedTabDetailsIndex
        }
        .animation(.smooth, value: selectedTabDetailsIndex)
    }

    @ViewBuilder
    private func modulesView(modules: [HModule]) -> some View {
        VStack(spacing: 16) {
            ForEach(modules) { module in
                ExpandingModuleView(module: module) { url in
                    viewModel.moduleItemDidTap(url: url, from: viewController)
                }
                .frame(minHeight: 44)
                .background(Color.backgroundLightest)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
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

extension CourseDetailsViewView {
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
    }
}
