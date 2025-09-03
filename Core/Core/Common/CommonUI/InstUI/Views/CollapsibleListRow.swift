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

        @State private var _isExpandedState: Bool
        private var _isExpandedBinding: Binding<Bool>?
        private var isExpanded: Binding<Bool> {
            _isExpandedBinding ?? $_isExpandedState
        }
        @State private var expandedState: CollapseButtonExpandedState

        public init(
            cell: Label,
            isExpanded: Binding<Bool>? = nil,
            isInitiallyExpanded: Bool = true,
            content: @escaping () -> Content
        ) {
            self.cell = cell
            self.content = content
            self._isExpandedState = isInitiallyExpanded
            self._isExpandedBinding = isExpanded
            self.expandedState = .init(isExpanded: isExpanded?.wrappedValue ?? isInitiallyExpanded)
        }

        // MARK: - Body

        public var body: some View {
            DisclosureGroup(
                isExpanded: isExpanded,
                content: content,
                label: { cell }
            )
            .disclosureGroupStyle(
                CollapsibleListRowDisclosureStyle()
            )
            .onChange(of: isExpanded.wrappedValue) {
                expandedState = .init(isExpanded: isExpanded.wrappedValue)
            }
            .accessibilityRepresentation {
                VStack {
                    cell
                        .accessibilityValue(expandedState.a11yValue)
                        .accessibilityAction(named: expandedState.a11yActionLabel) {
                            isExpanded.wrappedValue.toggle()
                        }
                    if isExpanded.wrappedValue {
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
                            CollapseButtonIcon(isExpanded: configuration.$isExpanded)
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

//#if DEBUG
//
//#Preview {
//    let count1 = 3
//    let count2 = 25
//    InstUI.BaseScreen(state: .data) { _ in
//        VStack(spacing: 0) {
//            InstUI.Divider()
//            InstUI.CollapsibleListRow(title: "First Section", itemCount: count1) {
//                VStack(spacing: 0) {
//                    ForEach(0..<count1, id: \.self) { index in
//                        Text(verbatim: "Item \(index)")
//                            .textStyle(.cellLabel)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .paddingStyle(set: .standardCell)
//                        InstUI.Divider(isLast: index == count1 - 1)
//                    }
//                }
//            }
//            InstUI.CollapsibleListRow(title: "Second Section", itemCount: count2) {
//                VStack(spacing: 0) {
//                    ForEach(0..<count2, id: \.self) { index in
//                        Text(verbatim: "Item \(index)")
//                            .textStyle(.cellLabel)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .paddingStyle(set: .standardCell)
//                        InstUI.Divider(isLast: index == count2 - 1)
//                    }
//                }
//            }
//        }
//    }
//}
//
//#endif
