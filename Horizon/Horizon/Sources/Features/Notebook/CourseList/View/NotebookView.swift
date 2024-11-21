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

struct NotebookView: View {

    @Bindable var state: NotebookViewModel

    private let beige = Color(hexString: "#FBF5ED")

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    NavigationBar(onBack: state.onBack)
                    SearchBar(onSearch: state.onSearch)
                        .padding(.vertical, 24)
                    ListViewItems(listItems: $state.listItems, onTap: state.onTap)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationBarBackButtonHidden(true)
            .contentMargins(.top, geometry.safeAreaInsets.top)
            .background(beige)
            .ignoresSafeArea(edges: .top)
        }
    }

    struct NavigationBar: View {
        var onBack: (() -> Void)?

        var body: some View {
            VStack {
                ZStack {
                    BackButton(action: onBack).frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: Alignment(horizontal: .leading, vertical: .center))
                    Text("Notebook").font(.regular20)
                }
            }
        }
    }

    struct SearchBar: View {

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

    struct ListViewItems: View {

        @Binding var listItems: [NotebookListItem]

        let onTap: ((NotebookListItem) -> Void)

        var body: some View {
            VStack(spacing: 16) {
                ForEach(listItems, id: \.id) { listItem in
                    ListViewItem(onTap: onTap, item: listItem)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct ListViewItem: View {
        let onTap: ((NotebookListItem) -> Void)

        let item: NotebookListItem

        var body: some View {
            VStack(alignment: .leading) {
                Text(item.institution).font(.regular12).multilineTextAlignment(.leading)
                Text(item.course).font(.regular22).multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
            .onTapGesture { onTap(item) }
        }
    }

    struct BackButton: View {
        let action: (() -> Void)?

        var body: some View {
            Button(action: action ?? {}) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.textDarkest)
                    .frame(width: 50, height: 50)
            }.background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
        }
    }
}

#if DEBUG
    struct NotebookView_Previews: PreviewProvider {
        static var previews: some View {
            NotebookView(
                state: NotebookViewModel(
                    router: AppEnvironment.shared.router,
                    getCoursesUseCase: GetCoursesUseCase()
                )
            )
        }
    }
#endif
