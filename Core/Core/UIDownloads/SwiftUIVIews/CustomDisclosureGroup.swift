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

struct CustomDisclosureGroup<Header: View, Content: View>: View {

    @Binding var isExpanded: Bool

    var onClick: () -> Void
    var animation: Animation?
    let header: Header
    let content: Content

    init(
        animation: Animation?,
        isExpanded: Binding<Bool>,
        onClick: @escaping () -> Void,
        header: () -> Header,
        content: () -> Content
    ) {
        self.onClick = onClick
        self._isExpanded = isExpanded
        self.animation = animation
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(animation) {
                        onClick()
                    }
                }
            if isExpanded {
                content
            }
        }
        .clipped()
    }
}
