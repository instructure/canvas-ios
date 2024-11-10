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

struct SearchDisplayContainerView<Info: SearchContextInfo, Descriptor: SearchDescriptor>: View {

    @Environment(\.viewController) private var controller
    @Environment(Info.environmentKeyPath) private var searchContext

    @State var searchText: String
    @State var filter: Descriptor.Filter?

    @State private var isFilterEditorPresented: Bool = false

    private let router: Router
    private let searchDescriptor: Descriptor

    init(
        ofInfoType type: Info.Type,
        router: Router,
        descriptor: Descriptor,
        searchText: String,
        filter: Descriptor.Filter?
    ) {
        self.router = router
        self.searchDescriptor = descriptor
        self._filter = State(initialValue: filter)
        self._searchText = State(initialValue: searchText)
    }

    public var body: some View {
        searchDescriptor
            .searchDisplayView($filter)
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
                        isFilterEditorPresented = true
                    } label: {
                        if filter != nil {
                            Image.filterSolid
                        } else {
                            Image.filterLine
                        }
                    }
                    .tint(Color.textLightest)
                }

                if let support = searchDescriptor.support {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            support.action.triggered(with: router, from: controller.value)
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
            .sheet(isPresented: $isFilterEditorPresented, content: {
                searchDescriptor.filterEditorView($filter)
            })
    }

    private var clearButtonColor: Color {
        return searchContext.clearButtonColor.flatMap({ Color(uiColor: $0) }) ?? .secondary
    }
}
