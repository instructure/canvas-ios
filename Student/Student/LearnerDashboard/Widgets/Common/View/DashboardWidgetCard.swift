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
import Core

struct DashboardWidgetCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        // The purpose of this layout is to keep the widget's border
        // on screen while the content's size changes. Instead of the border
        // fading with the states, it stays on screen and just resizes
        // to the new content's size.
        ZStack {
            content
        }
        .elevation(.cardLarge, background: .backgroundLightest)
    }
}

#if DEBUG

#Preview {
    DashboardWidgetCard {
        Text(verbatim: "Hello")
            .padding(50)
    }
}

#endif
