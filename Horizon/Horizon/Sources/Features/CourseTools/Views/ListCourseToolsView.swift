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

import HorizonUI
import SwiftUI

struct ListCourseToolsView: View {
    let items: [ToolLinkItem]
    let onSelect: (URL) -> Void
    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            ForEach(items) { item in
                Button {
                    if let url = item.url {
                        onSelect(url)
                    }
                } label: {
                    ToolLinkView(item: item)
                }
            }
        }
        .padding(.horizontal, .huiSpaces.space24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let url = "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D"
    ListCourseToolsView(
        items: [
            .init(
                id: "1",
                title: "LTI Placement Here 1",
                iconUrl: URL(string: url),
                url: nil
            ),
            .init(
                id: "2",
                title: "LTI Placement Here 2",
                iconUrl: nil,
                url: nil
            ),
            .init(
                id: "3",
                title: "LTI Placement Here 3",
                iconUrl: URL(string: url),
                url: nil
            )
        ]
    ) { _ in }
}
