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

    public struct CollapsibleSection<Content: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let title: String
        private let itemCount: Int?
        private let content: () -> Content

        @State private var isExpanded: Bool = true

        public init(
            title: String,
            itemCount: Int?,
            content: @escaping () -> Content
        ) {
            self.title = title
            self.itemCount = itemCount
            self.content = content
        }

        // MARK: - Body

        public var body: some View {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    content()
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(listLevelAccessibilityLabel)
                },
                label: {
                    Text(title)
                        .accessibilityLabel(headerAccessibilityLabel)
                }
            )
            .disclosureGroupStyle(.listSection)
        }

        private var headerAccessibilityLabel: String {
            guard let itemCount else { return title }
            return [title, String.localizedNumberOfItems(itemCount)]
                .joined(separator: ", ")
        }

        private var listLevelAccessibilityLabel: String? {
            guard let itemCount else { return nil }
            return String.localizedAccessibilityListCount(itemCount)
        }
    }
}

// MARK: - ListSectionDisclosureStyle

private struct ListSectionDisclosureStyle: DisclosureGroupStyle {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(
                action: {
                    withAnimation(.smooth(duration: 0.3)) {
                        configuration.isExpanded.toggle()
                    }
                },
                label: {
                    header(configuration: configuration)
                        .paddingStyle(set: .sectionHeader)
                        .contentShape(Rectangle())
                        .background(.backgroundLightest) // to stop collapsing views above showing through
                }
            )
            .buttonStyle(.plain)

            InstUI.Divider()

            if configuration.isExpanded {
                configuration.content
                    .background(.backgroundLightest) // to stop collapsing views above showing through
            }
        }
    }

    private func header(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 0) {
            configuration.label
                .textStyle(.sectionHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits([.isHeader])

            Image.chevronDown
                .scaledIcon(size: 18)
                .foregroundStyle(.textDark)
                .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
                .paddingStyle(.leading, .cellAccessoryPadding)
        }
    }
}

private extension DisclosureGroupStyle where Self == ListSectionDisclosureStyle {
    static var listSection: Self { ListSectionDisclosureStyle() }
}

// MARK: - Previews

#if DEBUG

#Preview {
    let count1 = 3
    let count2 = 25
    InstUI.BaseScreen(state: .data) { _ in
        VStack(spacing: 0) {
            InstUI.Divider()
            InstUI.CollapsibleSection(title: "First Section", itemCount: count1) {
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
            InstUI.CollapsibleSection(title: "Second Section", itemCount: count2) {
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
