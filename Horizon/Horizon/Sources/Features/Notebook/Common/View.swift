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
    @State private var title: String

    private let router: Router?

    private let builder: () -> AnyView

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
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    NavigationBar(title: title, backButton: BackButton(router: router))
                    builder()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity)
            .navigationBarBackButtonHidden(true)
            .contentMargins(.top, geometry.safeAreaInsets.top)
            .contentMargins(.bottom, geometry.safeAreaInsets.bottom)
            .background(Color(hexString: "#FBF5ED"))
            .ignoresSafeArea()
        }
    }
}

struct NavigationBar: View {

    @State var title: String

    let backButton: BackButton

    var body: some View {
        VStack {
            ZStack {
                backButton.frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: Alignment(horizontal: .leading, vertical: .center))
                Text(title).font(.regular20)
            }
        }
    }
}

struct BackButton: View {
    let action: (() -> Void)?

    let router: Router?

    @Environment(\.viewController) private var viewController

    init(action: @escaping (() -> Void)) {
        self.action = action
        router = nil
    }

    init(router: Router?) {
        self.router = router
        action = nil
    }

    var body: some View {
        Button(action: onBack) {
            Image(systemName: "arrow.left")
                .foregroundColor(.textDarkest)
                .frame(width: 50, height: 50)
        }.background(Color.white)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
    }

    func onBack() {
        if let router = router {
            router.pop(
                from: viewController
            )
            action?()
        }
    }
}

struct NotebookSearchBar: View {

    let onSearch: ((String) -> Void)

    @State private var searchText = ""

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $searchText, prompt: Text("Search"))
                .frame(height: 48)
                .padding(.leading, 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
                .onChange(of: searchText) { onSearch(searchText) }
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
        VStack(alignment: .leading) {
            builder()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
    }
}
