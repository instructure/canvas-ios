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

    @Environment(\.dismiss) private var dismiss
    @Environment(\.courseSmartSearchContext) private var searchContext

    @StateObject var viewModel: CourseSearchFilterEditorViewModel

    public init(model: CourseSearchFilterEditorViewModel) {
        self._viewModel = StateObject(wrappedValue: model)
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {

                    InstUI.Divider()

                    HStack {
                        Text("Sort By", bundle: .core)
                            .font(.semibold14)
                            .foregroundStyle(Color.textDark)
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.borderLight)

                    InstUI.Divider()

                    InstUI.RadioButtonCell(
                        title: "Relevance",
                        value: .relevance,
                        selectedValue: $viewModel.sortMode,
                        color: contextColor,
                        hasDivider: false
                    )

                    InstUI.Divider().padding(.horizontal, 16)

                    InstUI.RadioButtonCell(
                        title: "Type",
                        value: .type,
                        selectedValue: $viewModel.sortMode,
                        color: contextColor
                    )

                    HStack {
                        Text("Result type", bundle: .core)
                            .font(.semibold14)
                            .foregroundStyle(Color.textDark)
                        Spacer()
                        Button(
                            viewModel.allSelectionMode.title,
                            action: viewModel.allSelectionButtonTapped
                        )
                        .font(.semibold14)
                    }
                    .padding(16)
                    .background(Color.borderLight)

                    InstUI.Divider()

                    ForEach($viewModel.resultTypes, id: \.type) { type in
                        InstUI.CheckboxCell(
                            title: type.wrappedValue.type.title,
                            isSelected: type.checked,
                            color: contextColor,
                            hasDivider: false,
                            accessory: {
                                type.wrappedValue.type.icon.foregroundStyle(contextColor)
                            }
                        )

                        if viewModel.isLastResultType(type.wrappedValue) == false {
                            InstUI.Divider().padding(.horizontal, 16)
                        }
                    }

                    InstUI.Divider()
                }
            }
            .listStyle(.plain)
            .navigationTitle(Text("Search Preferences", bundle: .core))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.cancel()
                        dismiss()
                    } label: {
                        Text("Cancel", bundle: .core)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done", bundle: .core)
                    }
                }
            }
        }
        .tint(contextColor)
    }

    private var contextColor: Color {
        return Color(uiColor: searchContext.accentColor ?? .textDarkest)
    }
}

// MARK: - Helpers

private extension EdgeInsets {
    static var filterRow: EdgeInsets {
        return EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 12)
    }
}
