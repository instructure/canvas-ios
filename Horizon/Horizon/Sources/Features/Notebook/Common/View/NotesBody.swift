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

struct NotesBody<Content: View>: View {

    private let backgroundColor = Color(hexString: "#FBF5ED")!
    private let content: Content
    private let onBack: () -> Void
    @State private var title: String
    @Environment(\.viewController) private var viewController

    init(
        title: String,
        onBack: @escaping () -> Void,
        @ViewBuilder _ content: () -> Content
    ) {
        self.title = title
        self.onBack = onBack
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
            ToolbarItem(placement: .navigationBarLeading) { navBarButton }
        }
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .background(backgroundColor)
    }

    private var navBarButton: some View {
        Button {
            onBack()
        } label: {
            Image(systemName: "arrow.left")
                .tint(.backgroundDark)
                .frame(width: 40, height: 40)
                .background(Color.backgroundLightest)
                .clipShape(.circle)
                .shadow(color: .backgroundDark, radius: 2)
        }
    }
}
