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

struct SearchContentContainerView<Attributes: SearchViewAttributes, ViewProvider: SearchViewsProvider>: View {

    @Environment(\.viewController) private var controller
    @Environment(Attributes.Environment.keyPath) private var searchContext

    @State var searchText: String
    @State var filter: ViewProvider.Filter?

    @State private var editingFilter: ViewProvider.Filter?
    @State private var isFilterEditorPresented: Bool = false

    private let router: Router
    private let searchViewsProvider: ViewProvider

    init(
        ofAttributesType type: Attributes.Type,
        router: Router,
        provider: ViewProvider,
        searchText: String,
        filter: ViewProvider.Filter?
    ) {
        self.router = router
        self.searchViewsProvider = provider
        self._filter = State(initialValue: filter)
        self._editingFilter = State(initialValue: filter)
        self._searchText = State(initialValue: searchText)
    }

    public var body: some View {
        searchViewsProvider
            .contentView($filter)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .principal) {
                    SearchTextField(
                        text: $searchText,
                        prompt: searchContext.searchPrompt,
                        clearButtonColor: clearButtonColor
                    ) {
                        searchContext.didSubmit.send(searchText)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingFilter = filter
                        isFilterEditorPresented = true
                    } label: {
                        if filter?.isActive ?? false {
                            Image.filterSolid
                        } else {
                            Image.filterLine
                        }
                    }
                    .tint(Color.textLightest)
                }

                if let support = searchViewsProvider.support {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            support
                                .action
                                .trigger(for: searchContext, with: router, from: controller.value)
                        } label: {
                            support.icon.image()
                        }
                        .tint(Color.textLightest)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        router.dismiss(controller.value)
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .tint(Color.textLightest)
                }
            }
            .onChange(of: searchText) { newValue in
                searchContext.searchText.send(newValue)
            }
            .sheet(
                isPresented: $isFilterEditorPresented,
                onDismiss: {
                    // This is to only apply changes when user
                    // is done editing.
                    filter = editingFilter
                },
                content: {
                    searchViewsProvider.filterEditorView($editingFilter)
                }
            )
    }

    private var clearButtonColor: Color {
        return searchContext.accentColor.flatMap({ Color(uiColor: $0) }) ?? .secondary
    }
}
