//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct InboxFilterBar: View {

    public var body: some View {
        HStack(spacing: 0) {
            courseFilterButton
            Spacer(minLength: 22)
            scopeFilterButton
                .layoutPriority(1)
        }
        .frame(height: 81)
        .padding(.leading, 16)
        .padding(.trailing, 19)
        .background(Color.backgroundLightest)
    }

    private var courseFilterButton: some View {
        Button {

        } label: {
            HStack(spacing: 6) {
                Text("All Courses")
                    .lineLimit(1)
                    .font(.semibold22)
                    .foregroundColor(.textDarkest)
                Image
                    .arrowOpenDownSolid
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17)
            }
            .foregroundColor(.textDarkest)
        }
    }

    private var scopeFilterButton: some View {
        Button {

        } label: {
            HStack(spacing: 5) {
                Text("All")
                    .lineLimit(1)
                    .font(.regular16)
                Image
                    .arrowOpenDownSolid
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13)
            }
            .foregroundColor(Color(Brand.shared.linkColor))
        }
    }
}

#if DEBUG

struct InboxFilterBar_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            InboxFilterBar()
                .preferredColorScheme($0)
                .previewLayout(.sizeThatFits)
        }
    }
}

#endif
