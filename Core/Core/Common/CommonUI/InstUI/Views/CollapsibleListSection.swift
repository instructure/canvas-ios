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

    public struct CollapsibleListSection<Label: View, Content: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Label
        private let paddingSet: InstUI.Styles.PaddingSet
        private let accessoryIconSize: CGFloat
        private let content: () -> Content

        @State private var _isExpandedState: Bool
        private var _isExpandedBinding: Binding<Bool>?
        private var isExpanded: Binding<Bool> {
            _isExpandedBinding ?? $_isExpandedState
        }
        @State private var expandedState: CollapseButtonExpandedState

        private let headerAccessibilityLabel: String
        private let listLevelAccessibilityLabel: String?

        public init(
            title: String,
            customAccessibilityLabel: String? = nil,
            itemCount: Int?,
            paddingSet: InstUI.Styles.PaddingSet = .sectionHeader,
            accessoryIconSize: CGFloat = 18,
            isExpanded: Binding<Bool>? = nil,
            isInitiallyExpanded: Bool = true,
            content: @escaping () -> Content
        ) where Label == Text {
            self.init(
                label: Text(title),
                accessibilityLabel: customAccessibilityLabel ?? title,
                itemCount: itemCount,
                paddingSet: paddingSet,
                accessoryIconSize: accessoryIconSize,
                isExpanded: isExpanded,
                isInitiallyExpanded: isInitiallyExpanded,
                content: content
            )
        }

        public init(
            label: Label,
            accessibilityLabel: String,
            itemCount: Int?,
            paddingSet: InstUI.Styles.PaddingSet = .sectionHeader,
            accessoryIconSize: CGFloat = 18,
            isExpanded: Binding<Bool>? = nil,
            isInitiallyExpanded: Bool = true,
            content: @escaping () -> Content
        ) {
            self.label = label
            self.paddingSet = paddingSet
            self.accessoryIconSize = accessoryIconSize
            self.content = content

            self._isExpandedState = isInitiallyExpanded
            self._isExpandedBinding = isExpanded
            self.expandedState = .init(isExpanded: isExpanded?.wrappedValue ?? isInitiallyExpanded)

            self.headerAccessibilityLabel = [
                accessibilityLabel,
                String.format(numberOfItems: itemCount)
            ].accessibilityJoined()

            self.listLevelAccessibilityLabel = itemCount.map(String.format(accessibilityListCount:))
        }

        // MARK: - Body

        public var body: some View {
            // Using `Section` instead of `DisclosureGroup` to support pinning the header.
            // The downside is that a11y must be handled manually, approximating the `DisclosureGroup` behavior.
            Section(
                isExpanded: isExpanded,
                content: {
                    content()
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(listLevelAccessibilityLabel)
                },
                header: {
                    VStack(alignment: .leading, spacing: 0) {
                        Button(
                            action: {
                                withAnimation(.smooth(duration: 0.3)) {
                                    isExpanded.wrappedValue.toggle()
                                }
                            },
                            label: {
                                header()
                                    .paddingStyle(set: paddingSet)
                                    .contentShape(Rectangle())
                            }
                        )
                        .buttonStyle(.plain)

                        InstUI.Divider()
                    }
                }
            )
            .background(.backgroundLightest) // to stop collapsing views above showing through
            .onChange(of: isExpanded.wrappedValue) {
                expandedState = .init(isExpanded: isExpanded.wrappedValue)
            }
        }

        private func header() -> some View {
            HStack(alignment: .center, spacing: 0) {
                label
                    .textStyle(.sectionHeader)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CollapseButtonIcon(size: accessoryIconSize, isExpanded: isExpanded)
                    .paddingStyle(.leading, .cellAccessoryPadding)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(headerAccessibilityLabel)
            .accessibilityValue(expandedState.a11yValue)
            .accessibilityHint(expandedState.a11yHint)
            .accessibilityAddTraits([.isHeader])
        }
    }
}

// MARK: - Previews

#if DEBUG

#Preview {
    let count1 = 3
    let count2 = 25
    InstUI.BaseScreen(state: .data) { _ in
        VStack(spacing: 0) {
            InstUI.Divider()
            InstUI.CollapsibleListSection(title: "First Section", itemCount: count1) {
                VStack(spacing: 0) {
                    ForEach(0..<count1, id: \.self) { index in
                        Text(verbatim: "Item \(index)")
                            .textStyle(.cellLabel)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .paddingStyle(set: .standardCell)
                        InstUI.Divider(isLast: index == count1 - 1)
                    }
                }
            }
            InstUI.CollapsibleListSection(title: "Second Section", itemCount: count2) {
                VStack(spacing: 0) {
                    ForEach(0..<count2, id: \.self) { index in
                        Text(verbatim: "Item \(index)")
                            .textStyle(.cellLabel)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .paddingStyle(set: .standardCell)
                        InstUI.Divider(isLast: index == count2 - 1)
                    }
                }
            }
        }
    }
}

#endif
