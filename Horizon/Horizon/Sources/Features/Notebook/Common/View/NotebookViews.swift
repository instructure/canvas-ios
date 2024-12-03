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
import SwiftUICore

struct NotesBody: View {

    private let builder: () -> AnyView
    private let backgroundColor = Color(hexString: "#FBF5ED")!
    private let router: Router?
    @State private var title: String

    init(
        title: String,
        router: Router?,
        @ViewBuilder _ builder: @escaping () -> some View
    ) {
        self.title = title
        self.router = router
        self.builder = { AnyView(builder()) }
    }

    var body: some View {
        ScrollView {
            VStack {
                builder()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(router: router)
            }
        }
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .background(backgroundColor)
    }
}

struct IconButton: View {

    let action: (() -> Void)?

    let systemName: String

    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: systemName)
                .tint(.backgroundDark)
                .frame(width: 40, height: 40)
                .background(Color.backgroundLightest)
                .clipShape(.circle)
                .shadow(color: .backgroundDark, radius: 2)
        }
    }
}

struct BackButton: View {
    let router: Router?

    @Environment(\.viewController) private var viewController

    init(router: Router?) {
        self.router = router
    }

    var body: some View {
        IconButton(action: onBack, systemName: "arrow.left")
    }

    func onBack() {
        router?.pop(from: viewController)
    }
}

struct NotebookSearchBar: View {

    @Binding var term: String

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("",
                  text: $term,
                  prompt: Text(String(localized: "Search", bundle: .horizon))
                )
                .frame(height: 48)
                .padding(.leading, 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textDarkest)
                .padding(.leading, 16)
        }
    }
}

struct NotebookCard: View {
    private let builder: () -> AnyView

    init(@ViewBuilder _ builder: @escaping () -> some View) {
        self.builder = { AnyView(builder()) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            builder()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
    }
}
