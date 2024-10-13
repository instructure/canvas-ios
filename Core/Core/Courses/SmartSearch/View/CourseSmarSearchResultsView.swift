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
    @State private var selected: ID?

    let results: [SearchResult]

    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack(spacing: 0) {
                    CourseSearchResultsHeaderView()
                        .anchorPreference(
                            key: OffsetKey.self,
                            value: .top,
                            transform: { anchor in
                                return g[anchor].y
                            })
                    LazyVStack(spacing: 0) {
                        ForEach(results) { result in
                            let last = results.last?.id == result.id
                            CourseSearchResultRowView(selected: $selected, result: result, last: last)
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
            })
        }
    }
}

// MARK: - Grouped Results

struct CourseSmartSearchGroupedResultsView: View {

    @State private var resultSections: [SearchResultsSection]
    @State private var selected: ID?

    init(resultSections: [SearchResultsSection]) {
        self._resultSections = State(initialValue: resultSections)
    }

    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack(spacing: 0) {
                    CourseSearchResultsHeaderView()
                        .anchorPreference(
                            key: OffsetKey.self,
                            value: .top,
                            transform: { anchor in
                                return g[anchor].y
                            })
                    LazyVStack(spacing: 0) {

                        ForEach($resultSections, id: \.type) { sec in
                            let section = sec.wrappedValue
                            let title = "\(section.type.title) (\(section.results.count))"

                            DisclosureGroup(title, isExpanded: sec.expanded) {
                                ForEach(section.results) { result in
                                    let last = section.results.last?.id == result.id
                                    CourseSearchResultRowView(
                                        selected: $selected,
                                        result: result,
                                        showType: false,
                                        last: last
                                    )
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
            })
        }
    }
}

// MARK: - Helper Views

struct SearchDivider: View {
    var inset: Bool = true
    var body: some View {
        Rectangle()
            .fill(Color.borderMedium)
            .frame(height: 0.5)
            .padding(.horizontal, inset ? 16 : 0)
    }
}

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
            .overlay(alignment: .bottom, content: { SearchDivider(inset: false) })
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        if configuration.isExpanded {
            configuration.content
        }
    }
}

private extension DisclosureGroupStyle where Self == CourseSearchSectionDisclosureStyle {
    static var courseSearchResultSection: Self { CourseSearchSectionDisclosureStyle() }
}

// MARK: - Utils

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
