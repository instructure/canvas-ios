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

extension InstUI {

    public struct ListSectionHeader<ButtonLabel: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let title: String?
        private let itemCount: Int
        private let buttonLabel: ButtonLabel?
        private let buttonAction: (() -> Void)?

        public init(
            title: String?,
            itemCount: Int,
            buttonLabel: ButtonLabel?,
            buttonAction: (() -> Void)? = nil
        ) {
            self.title = title
            self.itemCount = itemCount
            self.buttonLabel = buttonLabel
            self.buttonAction = buttonAction
        }

        public init(title: String?, itemCount: Int) where ButtonLabel == SwiftUI.EmptyView {
            self.init(title: title, itemCount: itemCount, buttonLabel: nil)
        }

        @ViewBuilder
        public var body: some View {
            if let title {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Text(title)
                            .textStyle(.sectionHeader)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel(title + ", " + String.localizedAccessibilityListCount(itemCount))
                            .accessibilityAddTraits([.isHeader])

                        if let buttonLabel {
                            Button(
                                action: buttonAction ?? { },
                                label: {
                                    buttonLabel
                                        .font(.semibold14)
                                        .multilineTextAlignment(.trailing)
                                }
                            )
                            .paddingStyle(.leading, .cellAccessoryPadding)
                        }
                    }
                    .paddingStyle(set: .sectionHeader)

                    InstUI.Divider()
                }
            } else {
                SwiftUI.EmptyView()
            }
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        InstUI.Divider()
        InstUI.ListSectionHeader(title: "Section Header Cell", itemCount: 0)
        InstUI.ListSectionHeader(title: "Section Header with Button", itemCount: 0, buttonLabel: Text("Select all"))
        InstUI.ListSectionHeader(title: "Section Header with red Button", itemCount: 0, buttonLabel: Text("Delete all").foregroundStyle(Color.textDanger))
        InstUI.ListSectionHeader(title: "Section Header with custom styled Button", itemCount: 0, buttonLabel: Text("This is a big button").textStyle(.heading))
    }
}

#endif
