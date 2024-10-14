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

public struct SearchDisplayState {
    public static var empty = SearchDisplayState(isLoading: false, isPresented: false, isActive: false)

    public var isLoading: Bool
    public var isFiltersPresented: Bool
    public var isFiltersActive: Bool

    public init(isLoading: Bool, isPresented: Bool, isActive: Bool) {
        self.isLoading = isPresented
        self.isFiltersPresented = isPresented
        self.isFiltersActive = isActive
    }
}

public typealias CoreSearchDisplayProvider<Display: View> = (Binding<SearchDisplayState>) -> Display
public struct SearchDisplayContainerView<Display: View, Action: SearchSupportAction>: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.searchContext) private var searchContext

    @State var searchText: String
    @State var displayState: SearchDisplayState = .empty

    let displayContent: CoreSearchDisplayProvider<Display>
    let support: SearchSupportOption<Action>?

    init(
        searchText: String,
        support: SearchSupportOption<Action>?,
        display: @escaping CoreSearchDisplayProvider<Display>
    ) {
        self.displayContent = display
        self.support = support
        self._searchText = State(initialValue: searchText)
    }

    public var body: some View {
        displayContent($displayState)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .principal) {
                    SearchTextField(
                        text: $searchText,
                        prompt: Text("Search in this course"),
                        clearButtonColor: clearButtonColor
                    ) {
                        searchContext.didSubmit.send(searchText)
                    }
                }

                if displayState.isLoading == false {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            displayState.isFiltersPresented = true
                        } label: {
                            if displayState.isFiltersActive {
                                Image.filterSolid
                            } else {
                                Image.filterLine
                            }
                        }
                        .tint(.white)
                    }
                }

                if let support {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            support.action.triggered(with: env.router, from: controller.value)
                        } label: {
                            support.icon.image()
                        }
                        .tint(.white)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        env.router.dismiss(controller.value)
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .tint(.white)
                }
            }
            .onChange(of: searchText) { newValue in
                searchContext.searchText.send(newValue)
            }
    }

    private var clearButtonColor: Color {
        return searchContext.color.flatMap({ Color(uiColor: $0) }) ?? .secondary
    }
}
