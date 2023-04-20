//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct SnackBarView: View {
    public let text: String

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSize
    private let padding: CGFloat = 16
    private var maxWidth: CGFloat? {
        horizontalSize == .compact ? .infinity : nil
    }

    public var body: some View {
        Text(text)
            .lineLimit(2)
            .frame(minWidth: 300, maxWidth: maxWidth, alignment: .leading)
            .font(.regular14, lineHeight: .fit)
            .padding(padding)
            // Use textLightest unconditionally when palette is updated
            .foregroundColor(colorScheme == .light ? .textLightest : .licorice)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                    // Use backgroundDarkest unconditionally when palette is updated
                    .foregroundColor(colorScheme == .dark ? .white : .backgroundDarkest)
            }
            .padding(.horizontal, padding)
            .frame(minHeight: 48)
            .padding(.bottom, padding)
    }
}

#if DEBUG

struct SnackBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundLightest
            VStack(spacing: 0) {
                SnackBarView(text: "File deleted.")
                SnackBarView(text:
                                """
                                Really long text to check what happens when it spans to \
                                multiple lines. Really long text to check what \
                                happens when it spans to multiple lines. Really long \
                                text to check what happens when it spans to multiple \
                                lines.
                                """)
            }
        }
        .background(.red)
        .frame(maxHeight: .infinity)
    }
}

#endif
