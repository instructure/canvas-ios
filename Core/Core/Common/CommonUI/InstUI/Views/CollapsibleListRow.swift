//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

extension InstUI {

    public struct CollapsibleListRow<Label: View, Content: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let cell: Label
        private let content: () -> Content

        @State private var isExpanded: Bool
        @State private var expandedState: CollapseButtonExpandedState

        public init(
            cell: Label,
            isInitiallyExpanded: Bool = true,
            content: @escaping () -> Content
        ) {
            self.cell = cell
            self.content = content

            self.isExpanded = isInitiallyExpanded
            self.expandedState = .init(isExpanded: isInitiallyExpanded)
        }

        // MARK: - Body

        public var body: some View {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: content,
                label: { cell }
            )
            .disclosureGroupStyle(
                CollapsibleListRowDisclosureStyle()
            )
            .onChange(of: isExpanded) {
                expandedState = .init(isExpanded: isExpanded)
            }
            .accessibilityRepresentation {
                VStack {
                    cell
                        .accessibilityValue(expandedState.a11yValue)
                        .accessibilityAction(named: expandedState.a11yActionLabel) {
                            isExpanded.toggle()
                        }
                    if isExpanded {
                        content()
                    }
                }
                .accessibilityElement(children: .contain)
            }
        }
    }

    private struct CollapsibleListRowDisclosureStyle: DisclosureGroupStyle {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    configuration.label
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(
                        action: {
                            withAnimation(.smooth(duration: 0.3)) {
                                configuration.isExpanded.toggle()
                            }
                        },
                        label: {
                            InstUI.CollapseButtonIcon(isExpanded: configuration.$isExpanded)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .paddingStyle(set: .standardCell)
                                .contentShape(Rectangle())
                                .accessibilityHidden(true)
                        }
                    )
                    .buttonStyle(.plain)
                }

                if configuration.isExpanded {
                    configuration.content
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(.backgroundLightest) // to stop collapsing views above showing through
        }
    }
}

// MARK: - Previews

#if DEBUG

#Preview {
    let count1 = 3
    let count2 = 25
    PreviewContainer {
        InstUI.Divider()
        InstUI.CollapsibleListRow(cell: InstUI.LabelCell(label: Text("First Row"))) {
            VStack(spacing: 0) {
                ForEach(0..<count1, id: \.self) { index in
                    ItemCell(index: index)
                }
            }
        }
        InstUI.Divider()
        InstUI.CollapsibleListRow(cell: InstUI.LabelCell(label: Text("Second Row")), isInitiallyExpanded: false) {
            VStack(spacing: 0) {
                ForEach(0..<count2, id: \.self) { index in
                    ItemCell(index: index)
                }
            }
        }
        InstUI.Divider()
    }
}

private struct ItemCell: View {
    let index: Int

    var body: some View {
        VStack(spacing: 0) {
            InstUI.Divider(.padded)
            Text(verbatim: "Item \(index)")
                .textStyle(.cellLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
                .paddingStyle(set: .standardCell)
        }
        .paddingStyle(.leading, .standard)
    }
}

#endif
