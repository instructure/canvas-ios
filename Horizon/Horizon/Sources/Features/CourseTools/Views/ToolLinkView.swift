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

import Core
import HorizonUI
import SwiftUI

struct ToolLinkView: View {
    let item: ToolLinkItem

    var body: some View {
        HStack(spacing: .huiSpaces.space8) {
            if let icon = item.iconUrl {
                RemoteImage(icon, size: 32)
                    .clipShape(.circle)
            }
            Text(item.title)
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.text.body)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 32)

            Spacer()
            Image.huiIcons.openInNew
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.huiColors.icon.default)
        }
        .padding(.leading, item.iconUrl == nil ? .huiSpaces.space24 :.huiSpaces.space12)
        .padding(.trailing, .huiSpaces.space24)
        .padding(.vertical, .huiSpaces.space10)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level6)
        .huiElevation(level: .level4)
    }
}

#Preview {
    ZStack {
        Color.huiColors.surface.pagePrimary
        let url = "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D"
        ToolLinkView(item: .init(id: "1", title: "LTI Placement Here", iconUrl: URL(string: url), url: nil))
            .padding()
    }
}
