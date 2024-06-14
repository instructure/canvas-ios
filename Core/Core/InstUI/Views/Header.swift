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

    public struct Header: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let title: String
        private let subtitle: String?

        public init(
            title: String,
            subtitle: String? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
        }

        @ViewBuilder
        public var body: some View {
            VStack(
                alignment: .leading,
                spacing: InstUI.Styles.Padding.textVertical.rawValue
            ) {
                Text(title)
                    .textStyle(.heading)
                if let subtitle {
                    Text(subtitle)
                        .textStyle(.infoDescription)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .paragraphStyle(.heading)
        }
    }
}

#if DEBUG

#Preview("Title") {
    InstUI.Header(title: InstUI.PreviewData.loremIpsumShort)
}

#Preview("Title + Subtitle") {
    InstUI.Header(
        title: InstUI.PreviewData.loremIpsumShort,
        subtitle: InstUI.PreviewData.loremIpsumMedium
    )
}

#endif
