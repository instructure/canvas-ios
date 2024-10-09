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

enum SearchResultSortMode {
    case relevance
    case type
}

public struct SearchResultFilter {
    let sortMode: SearchResultSortMode
    let includedTypes: [SearchResult.ContentType]
    let predicate: (SearchResult) -> Bool

    init(sortMode: SearchResultSortMode = .relevance, includedTypes: [SearchResult.ContentType]) {
        self.sortMode = sortMode
        self.includedTypes = includedTypes
        self.predicate = { result in
            return includedTypes.contains(result.content_type)
        }
    }
}

extension SearchResult.ContentType {
    static var filterableTypes: [SearchResult.ContentType] {
        return [.assignment, .page, .announcement, .discussion]
    }
}

public struct SmartSearchFiltersView: View {
    typealias ContentType = SearchResult.ContentType

    struct ResultType {
        let contentType: ContentType
        var checked: Bool = true
    }

    @Environment(\.dismiss) var dismiss
    @Environment(\.searchContext) var searchContext

    @State var sortMode: SearchResultSortMode? = .relevance
    @State var resultTypes: [ResultType]

    public init(filter: SearchResultFilter?, onSubmit: @escaping (SearchResultFilter?) -> Void) {
        self.onSubmit = onSubmit
        self._sortMode = State(initialValue: filter?.sortMode ?? .relevance)

        let included = filter?.includedTypes.nilIfEmpty ?? ContentType.filterableTypes
        self._resultTypes = State(
            initialValue: ContentType.filterableTypes.map({ type in
                let checked = included.contains(type)
                return ResultType(contentType: type, checked: checked)
            })
        )
    }

    let onSubmit: (SearchResultFilter?) -> Void

    public var body: some View {
        NavigationView {
            List {

                Section {

                    InstUI.RadioButtonCell(
                        title: "Relevance",
                        value: .relevance,
                        selectedValue: $sortMode,
                        color: color
                    )
                    .listRowInsets(.filterRow)
                    .listRowSeparator(.hidden)

                    InstUI.RadioButtonCell(
                        title: "Type",
                        value: .type,
                        selectedValue: $sortMode,
                        color: color
                    )
                    .listRowInsets(.filterRow)
                    .listRowSeparator(.hidden)
                } header: {
                    Text("Sort By").font(.semibold14)
                }

                Section {
                    ForEach($resultTypes, id: \.contentType) { type in
                        HStack {
                            InstUI.CheckboxCell(
                                title: type.wrappedValue.contentType.title,
                                isSelected: type.checked,
                                color: color
                            )
                            Spacer()
                            type.wrappedValue.contentType.icon.foregroundStyle(color)
                        }
                        .listRowInsets(.filterRow)
                        .listRowSeparator(.hidden)
                    }
                } header: {
                    HStack {
                        Text("Result type").font(.semibold14)
                        Spacer()
                        Button(allSelected ? "Deselect all" : "Select all") {
                            if allSelected {
                                $resultTypes.forEach { type in
                                    type.checked.wrappedValue = false
                                }
                            } else {
                                $resultTypes.forEach { type in
                                    type.checked.wrappedValue = true
                                }
                            }
                        }
                        .font(.semibold14)
                    }
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Search Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onSubmit(filter)
                        dismiss()
                    }
                }
            }
        }
        .tint(color)
    }

    var filter: SearchResultFilter? {
        let allChecked = resultTypes.allSatisfy({ $0.checked })
        let allUnchecked = resultTypes.allSatisfy({ $0.checked == false })

        if (sortMode ?? .relevance) == .relevance,
            allChecked || allUnchecked { return nil } // This is invalid case

        return SearchResultFilter(
            sortMode: sortMode ?? .relevance,
            includedTypes: resultTypes
                .filter({ $0.checked })
                .map({ $0.contentType })
        )
    }

    var allSelected: Bool {
        return resultTypes.allSatisfy({ $0.checked })
    }

    var color: Color {
        return Color(uiColor: searchContext.color ?? .textDarkest)
    }
}

extension EdgeInsets {
    static var filterRow: EdgeInsets {
        return EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 12)
    }
}
