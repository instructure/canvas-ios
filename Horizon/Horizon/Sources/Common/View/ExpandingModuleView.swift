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

import Core
import SwiftUI

struct ExpandingModuleView: View {
    let title: String
    let items: [HModuleItem]
    let routeToURL: (URL) -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack(alignment: .center) {
                    Size14RegularTextDarkestTitle(title: title.uppercased())
                    Spacer()
                    Image(systemName: "chevron.down")
                        .tint(Color.textDark)
                        .frame(width: 18, height: 18)
                        .rotationEffect(isExpanded ? .degrees(-180) : .degrees(0))
                }
                .padding(.vertical, 16)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(items) { item in
                        Button {
                            if let url = item.htmlURL {
                                routeToURL(url)
                            }
                        } label: {
                            ProgramItemView(
                                title: item.title,
                                subtitle: "Placeholder Text",
                                duration: "20 mins"
                            )
                            .padding(.all, 12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.backgroundLight)
                    .padding(.leading, 32)
                }
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 16)
        .animation(.easeOut, value: isExpanded)
    }
}

#Preview {
    ExpandingModuleView(
        title: "Intro Module",
        items: [
            .init(id: "1", title: "Intro to biology", htmlURL: nil),
            .init(id: "2", title: "Intro to sports", htmlURL: nil)
        ],
        routeToURL: { _ in }
    )
}