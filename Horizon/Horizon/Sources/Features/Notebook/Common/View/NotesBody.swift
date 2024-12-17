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
import HorizonUI

struct NotesBody<Content: View, Leading: View, Trailing: View>: View {
    private let backgroundColor = HorizonUI.colors.surface.pagePrimary
    private let content: Content
    private let leading: Leading?
    @State private var title: String
    private let trailing: Trailing?

    init(
        title: String,
        @ViewBuilder leading: () -> Leading?,
        @ViewBuilder trailing: () -> Trailing?,
        @ViewBuilder _ content: () -> Content
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack { content }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(title)
        .toolbar {
            if let leading = leading {
                ToolbarItem(placement: .navigationBarLeading) { leading }
            }
            if let trailing = trailing {
                ToolbarItem(placement: .navigationBarTrailing) { trailing }
            }
        }
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .background(backgroundColor)
    }
}

#Preview {
    NavigationView {
        NotesBody(
            title: "Title",
            leading: {
                Text("Leading")
            },
            trailing: {
                Text("Trailing")
            }
        ) {
            Text("Content")
        }
    }
}
