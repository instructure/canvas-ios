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

struct LinkDownloadingHeader<Destination: View>: View {

    let destination: Destination?
    let title: String

    @State private var linkIsActive: Bool = false

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .font(.bold17)
                .foregroundColor(.textDarkest)
            Spacer()
            if let destination = destination {
                NavigationLink(
                    destination: destination,
                    isActive: $linkIsActive
                ) {
                    SwiftUI.EmptyView()
                }.hidden()
                Text("Show all")
                    .font(.semibold16)
                    .foregroundColor(Color(Brand.shared.linkColor))
                    .onTapGesture {
                        linkIsActive = true
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .listRowInsets(EdgeInsets())
        .buttonStyle(PlainButtonStyle())
        .listRowSeparator(.hidden)
    }
}
