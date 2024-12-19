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
        private let buttonLabel: ButtonLabel?
        private let buttonAction: (() -> Void)?

        public init(
            title: String?,
            buttonLabel: ButtonLabel?,
            buttonAction: (() -> Void)? = nil
        ) {
            self.title = title
            self.buttonLabel = buttonLabel
            self.buttonAction = buttonAction
        }

        public init(title: String?) where ButtonLabel == SwiftUI.EmptyView {
            self.init(title: title, buttonLabel: nil)
        }

        @ViewBuilder
        public var body: some View {
            if let title {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Text(title)
                            .font(.semibold14)
                            .foregroundStyle(Color.textDark)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityAddTraits([.isHeader])

                        if let buttonLabel {
                            Button(
                                action: buttonAction ?? { },
                                label: { buttonLabel.font(.semibold14) }
                            )
                        }
                    }
                    .paddingStyle(.all, .standard)

                    InstUI.Divider()
                }
                .background(Color.backgroundLight)
            } else {
                SwiftUI.EmptyView()
            }
        }
    }
}

#if DEBUG

#Preview {
    InstUI.ListSectionHeader(title: "Section Header Cell")
}

#endif
