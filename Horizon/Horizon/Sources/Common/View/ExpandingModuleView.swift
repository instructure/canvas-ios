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

struct ExpandingModuleTitle: Identifiable {
    let id = UUID().uuidString
    let title: String
}

struct ExpandingModuleView: View {
    let title: String
    let items: [ExpandingModuleTitle]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack(alignment: .bottom) {
                    SectionTitleView(title: title.uppercased())
                    Spacer()
                    Image(systemName: "chevron.down")
                        .tint(Color.textDark)
                        .frame(width: 18, height: 18)
                        .rotationEffect(isExpanded ? .degrees(-180) : .degrees(0))
                }
            }

            if isExpanded {
                VStack(alignment: .leading) {
                    ForEach(items) { item in
                        Text(item.title)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.backgroundLight)
                }
                .padding()
            }
        }
        .animation(.easeOut, value: isExpanded)
    }
}

#Preview {
    ExpandingModuleView(
        title: "week 1",
        items: [ExpandingModuleTitle(title: "Quiz"), ExpandingModuleTitle(title: "Assignment")]
    )
}
