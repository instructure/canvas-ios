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

public struct CourseSmartSearchFilterEditorView: View {
    private typealias ContentType = CourseSmartSearchResult.ContentType

    private struct ResultType {
        let contentType: ContentType
        var checked: Bool = true
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.courseSmartSearchContext) private var searchContext

    @State private var sortMode: CourseSmartSearchFilter.SortMode? = .relevance
    @State private var resultTypes: [ResultType]

    let onSubmit: (CourseSmartSearchFilter?) -> Void

    public init(filter: CourseSmartSearchFilter?, onSubmit: @escaping (CourseSmartSearchFilter?) -> Void) {
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

    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {

                    InstUI.Divider()

                    HStack {
                        Text("Sort By").font(.semibold14).foregroundStyle(Color.textDark)
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.borderLight)

                    InstUI.Divider()

                    InstUI.RadioButtonCell(
                        title: "Relevance",
                        value: .relevance,
                        selectedValue: $sortMode,
                        color: contextColor,
                        seperator: false
                    )

                    InstUI.Divider().padding(.horizontal, 16)

                    InstUI.RadioButtonCell(
                        title: "Type",
                        value: .type,
                        selectedValue: $sortMode,
                        color: contextColor
                    )

                    HStack {
                        Text("Result type").font(.semibold14).foregroundStyle(Color.textDark)
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
                    .padding(16)
                    .background(Color.borderLight)

                    InstUI.Divider()

                    ForEach($resultTypes, id: \.contentType) { type in
                        InstUI.CheckboxCell(
                            title: type.wrappedValue.contentType.title,
                            isSelected: type.checked,
                            color: contextColor,
                            seperator: false,
                            icon: {
                                type.wrappedValue.contentType.icon.foregroundStyle(contextColor)
                            }
                        )

                        if type.wrappedValue.contentType != resultTypes.last?.contentType {
                            InstUI.Divider().padding(.horizontal, 16)
                        }
                    }

                    InstUI.Divider()
                }
            }
            .listStyle(.plain)
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
        .tint(contextColor)
    }

    private var filter: CourseSmartSearchFilter? {
        let allChecked = resultTypes.allSatisfy({ $0.checked })
        let allUnchecked = resultTypes.allSatisfy({ $0.checked == false })

        if (sortMode ?? .relevance) == .relevance,
            allChecked || allUnchecked { return nil } // This is invalid case

        return CourseSmartSearchFilter(
            sortMode: sortMode ?? .relevance,
            includedTypes: resultTypes
                .filter({ $0.checked })
                .map({ $0.contentType })
        )
    }

    private var allSelected: Bool {
        return resultTypes.allSatisfy({ $0.checked })
    }

    private var contextColor: Color {
        return Color(uiColor: searchContext.info.color ?? .textDarkest)
    }
}

// MARK: - Helpers

private extension EdgeInsets {
    static var filterRow: EdgeInsets {
        return EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 12)
    }
}
