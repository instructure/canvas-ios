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
        private let headerAccessibilityLabel: String
        private let listLevelAccessibilityLabel: String?
        private let headerIdentifier: String?

        private let config: Config
        private let content: Content

        @Binding private var isExpanded: Bool
        @State private var expandedState: CollapseButtonExpandedState

        public init(
            title: String,
            @ViewBuilder label: (String) -> Label = { Text($0) },
            itemCount: Int?,
            headerIdentifier: String? = nil,
            config: Config = .init(),
            isExpanded: Binding<Bool>,
            @ViewBuilder content: () -> Content
        ) {
            if let itemCount {
                let visibleTitle = config.showItemCount ? String.format(countSuffixed: title, count: itemCount) : title
                self.label = label(visibleTitle)
                self.headerAccessibilityLabel = [title, String.format(numberOfItems: itemCount)]
                    .joined(separator: ", ")
                self.listLevelAccessibilityLabel = config.readListItemCount ? String.format(accessibilityListCount: itemCount) : nil
            } else {
                self.label = label(title)
                self.headerAccessibilityLabel = title
                self.listLevelAccessibilityLabel = nil
            }

            self.headerIdentifier = headerIdentifier
            self.config = config
            self.content = content()

            self._isExpanded = isExpanded
            self.expandedState = .init(isExpanded: isExpanded.wrappedValue)

        }

        // MARK: - Body

        public var body: some View {
            // Using `Section` instead of `DisclosureGroup` to support pinning the header.
            // The downside is that a11y must be handled manually, approximating the `DisclosureGroup` behavior.
            Section(
                isExpanded: $isExpanded,
                content: {
                    content
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(listLevelAccessibilityLabel)
                },
                header: {
                    VStack(alignment: .leading, spacing: 0) {
                        Button(
                            action: {
                                withAnimation(.smooth(duration: 0.3)) {
                                    isExpanded.toggle()
                                }
                            },
                            label: {
                                header
                                    .paddingStyle(set: config.headerPaddingSet)
                                    .contentShape(Rectangle())
                            }
                        )
                        .buttonStyle(.plain)

                        InstUI.Divider(config.headerDividerStyle)
                    }
                }
            )
            .background(config.sectionBackgroundColor) // to stop collapsing views above showing through
            .onChange(of: isExpanded) {
                expandedState = .init(isExpanded: isExpanded)
            }
        }

        private var header: some View {
            HStack(alignment: .center, spacing: 0) {
                label
                    .textStyle(.sectionHeader)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CollapseButtonIcon(size: config.collapseIconSize, isExpanded: $isExpanded)
                    .paddingStyle(.leading, .cellAccessoryPadding)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(headerAccessibilityLabel)
            .accessibilityValue(expandedState.a11yValue)
            .accessibilityHint(expandedState.a11yHint)
            .accessibilityAddTraits([.isHeader])
            .identifier(headerIdentifier)
        }
    }
}

// MARK: - Config

extension InstUI.CollapsibleListSection {

    public struct Config: Equatable {
        let showItemCount: Bool
        let readListItemCount: Bool
        let headerPaddingSet: InstUI.Styles.PaddingSet
        let collapseIconSize: CGFloat
        let headerDividerStyle: InstUI.Divider.Style
        let sectionBackgroundColor: Color

        public init(
            showItemCount: Bool = false,
            readListItemCount: Bool = true,
            headerPaddingSet: InstUI.Styles.PaddingSet = .sectionHeader,
            collapseIconSize: CGFloat = 18,
            headerDividerStyle: InstUI.Divider.Style = .full,
            sectionBackgroundColor: Color = .backgroundLightest
        ) {
            self.showItemCount = showItemCount
            self.readListItemCount = readListItemCount
            self.headerPaddingSet = headerPaddingSet
            self.collapseIconSize = collapseIconSize
            self.headerDividerStyle = headerDividerStyle
            self.sectionBackgroundColor = sectionBackgroundColor
        }
    }
}

// MARK: - Previews

#if DEBUG

#Preview {
    @Previewable @State var isExpanded1: Bool = true
    @Previewable @State var isExpanded2: Bool = true
    let count1 = 3
    let count2 = 25

    InstUI.BaseScreen(state: .data) { _ in
        VStack(spacing: 0) {
            InstUI.Divider()
            InstUI.CollapsibleListSection(title: "First Section", itemCount: count1, isExpanded: $isExpanded1) {
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
            InstUI.CollapsibleListSection(title: "Second Section", itemCount: count2, isExpanded: $isExpanded2) {
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
