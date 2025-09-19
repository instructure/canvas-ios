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

    public struct ContextItemListCell<Icon: View, Labels: View, Accessory: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let icon: Icon
        private let labels: Labels
        private let accessory: Accessory
        private let isLastItem: Bool?
        private let action: () -> Void

        public init(
            @ViewBuilder icon: () -> Icon,
            @ViewBuilder labels: () -> Labels,
            @ViewBuilder accessory: () -> Accessory = { SwiftUI.EmptyView() },
            isLastItem: Bool?,
            action: @escaping () -> Void
        ) {
            self.icon = icon()
            self.labels = labels()
            self.accessory = accessory()
            self.isLastItem = isLastItem
            self.action = action
        }

        public var body: some View {
            VStack(spacing: 0) {
                Button {
                    action()
                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .top, spacing: 0) {
                            icon
                                .applyTint()
                                .paddingStyle(.trailing, .cellIconText)
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 2) {
                                labels
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        accessory
                            .paddingStyle(.leading, .cellAccessoryPadding)
                    }
                    .paddingStyle(set: .iconCell)
                    .contentShape(Rectangle())
                }
                .background(.backgroundLightest)
                .buttonStyle(.tintedContextButton)

                if let isLastItem {
                    InstUI.Divider(isLast: isLastItem)
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG

#Preview {
    PreviewContainer {
        let date = Date.now.dateTimeString

        InstUI.ContextItemListCell(
            icon: { Image.assignmentLine.scaledIcon() },
            labels: {
                Text("Assignment 1").textStyle(.cellLabel)
                Text(date).textStyle(.cellLabelSubtitle)
            },
            isLastItem: false,
            action: {}
        )

        InstUI.ContextItemListCell(
            icon: { Image.assignmentLine.scaledIcon() },
            labels: {
                Text("Assignment 2").textStyle(.cellLabel)
                Text(verbatim: .loremIpsumMedium).textStyle(.cellLabelSubtitle)
            },
            isLastItem: false,
            action: {}
        )
        .tint(.textSuccess)

        InstUI.ContextItemListCell(
            icon: { Image.assignmentLine.scaledIcon() },
            labels: {
                Text("Assignment 3").textStyle(.cellLabel)
                Text(verbatim: .loremIpsumMedium).textStyle(.cellLabelSubtitle)
            },
            accessory: { InstUI.DisclosureIndicator() },
            isLastItem: true,
            action: {}
        )
    }
    .tint(.course10)
}

#endif
