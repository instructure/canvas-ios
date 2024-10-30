//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public struct ListSectionHeaderOld<Content: View>: View {
    public let content: Content
    private let isLarge: Bool
    private let backgroundColor: Color

    public init(
        isLarge: Bool = false,
        backgroundColor: Color = .backgroundGrouped,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isLarge = isLarge
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InstUI.Divider()
            content
                .font(.semibold14)
                .foregroundColor(.textDark)
                .padding(16)
                .padding(.vertical, isLarge ? 0 : -12)
            InstUI.Divider()
        }
        .background(backgroundColor)
    }
}

#if DEBUG

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        ListSectionHeaderOld { Text(verbatim: "Hello, world!") }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

#endif
