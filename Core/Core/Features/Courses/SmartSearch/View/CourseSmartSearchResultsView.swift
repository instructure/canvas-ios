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

import SwiftUI

struct CourseSmartSearchResultsView: View {
    @Environment(\.viewController) private var controller

    let course: Course?
    let results: [CourseSmartSearchResult]

    @State private var selectedId: ID?

    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack(spacing: 0) {
                    CourseSearchResultsHeaderView(course: course)
                        .anchorPreference(
                            key: OffsetKey.self,
                            value: .top,
                            transform: { anchor in
                                return g[anchor].y
                            })
                    LazyVStack(spacing: 0) {
                        ForEach(results) { result in
                            CourseSearchResultRowView(selectedId: $selectedId, result: result)
                            RowDivider(withPadding: results.last?.id != result.id)
                        }
                    }
                    .safeAreaInset(edge: .bottom, content: {
                        Color.backgroundLightest.frame(height: 50)
                    })
                    .background(Color.backgroundLightest)
                }
            }
            .backgroundPreferenceValue(OffsetKey.self, { offset in
                VStack {
                    Color.backgroundLight.frame(height: max(offset, 0))
                    Color.backgroundLightest.frame(maxHeight: .infinity)
                }
                .ignoresSafeArea()
            })
        }
        .onDidAppear {
            guard isContainerCollapsed else { return }
            withAnimation {
                selectedId = nil
            }
        }
    }

    private var isContainerCollapsed: Bool {
        return controller.value.splitViewController?.isCollapsed ?? true
    }
}

// MARK: - Grouped Results

struct CourseSmartSearchGroupedResultsView: View {
    @Environment(\.viewController) private var controller

    private let course: Course?
    @State private var resultSections: [CourseSmartSearchResultsSection]
    @State private var selectedId: ID?

    init(course: Course?, resultSections: [CourseSmartSearchResultsSection]) {
        self.course = course
        self._resultSections = State(initialValue: resultSections)
    }

    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack(spacing: 0) {
                    CourseSearchResultsHeaderView(course: course)
                        .anchorPreference(
                            key: OffsetKey.self,
                            value: .top,
                            transform: { anchor in
                                return g[anchor].y
                            })
                    LazyVStack(spacing: 0) {

                        ForEach($resultSections, id: \.type) { sectionBinding in
                            let section = sectionBinding.wrappedValue
                            let title = "\(section.type.title) (\(section.results.count))"

                            DisclosureGroup(title, isExpanded: sectionBinding.expanded) {
                                ForEach(section.results) { result in
                                    CourseSearchResultRowView(
                                        selectedId: $selectedId,
                                        result: result,
                                        showsType: false
                                    )
                                    RowDivider(withPadding: section.results.last?.id != result.id)
                                }
                            }
                            .disclosureGroupStyle(.courseSearchResultSection)
                        }
                    }
                    .safeAreaInset(edge: .bottom, content: {
                        Color.backgroundLightest.frame(height: 50)
                    })
                    .background(Color.backgroundLightest)
                }
            }
            .backgroundPreferenceValue(OffsetKey.self, { offset in
                VStack {
                    Color.backgroundLight.frame(height: max(offset, 0))
                    Color.backgroundLightest.frame(maxHeight: .infinity)
                }
                .ignoresSafeArea()
            })
        }
        .onDidAppear {
            guard isContainerCollapsed else { return }
            withAnimation {
                selectedId = nil
            }
        }
    }

    private var isContainerCollapsed: Bool {
        return controller.value.splitViewController?.isCollapsed ?? true
    }
}

// MARK: - Helper Views

private struct CourseSearchSectionDisclosureStyle: DisclosureGroupStyle {

    @ScaledMetric private var uiScale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .center) {
                configuration
                    .label
                    .font(.semibold14)
                    .foregroundStyle(Color.textDark)
                Spacer()
                Image
                    .chevronDown
                    .size(uiScale.iconScale * 18)
                    .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        RowDivider()
        if configuration.isExpanded {
            configuration.content
        }
    }
}

private extension DisclosureGroupStyle where Self == CourseSearchSectionDisclosureStyle {
    static var courseSearchResultSection: Self { CourseSearchSectionDisclosureStyle() }
}

private struct RowDivider: View {
    var withPadding: Bool = false
    var body: some View {
        SwiftUI
            .Divider()
            .overlay {
                // This is to fix an issue on collapse/expanding of disclosure group
                Color.borderMedium.frame(maxHeight: 0.5)
            }
            .padding(.horizontal, withPadding ? 16 : 0)
    }
}

// MARK: - Utils

private struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
