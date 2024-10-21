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

    public struct ListSectionHeader: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let title: String?

        public init(title: String?) {
            self.title = title
        }

        @ViewBuilder
        public var body: some View {
            if let title {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.semibold14)
                        .foregroundStyle(Color.textDark)
                        .paddingStyle(.all, .standard)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    InstUI.Divider()
                }
                .background(Color.backgroundLight)
                .accessibilityAddTraits([.isHeader])
            } else {
                SwiftUI.EmptyView()
            }
        }
    }

    public struct ListSectionCollapsableHeader: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let title: String?
        private let icon: AnyView?

        public init(title: String?, icon: AnyView? = nil) {
            self.title = title
            self.icon = icon
        }

        @ViewBuilder
        public var body: some View {
            if let title {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.semibold14)
                        .foregroundStyle(Color.textDark)
                        .paddingStyle(.all, .standard)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    InstUI.Divider()
                    icon
                }
                .background(Color.backgroundLight)
                .accessibilityAddTraits([.isHeader])
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
